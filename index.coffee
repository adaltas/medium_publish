medium = require 'medium-sdk'

app = require('parameters')
  name: 'medium_post'
  description: 'Post draft articles on Medium'
  options:
    source:
      required: true
      description: 'Path to the Mardown source code of the article.'
    url:
      required: true
      description: 'URL where the article is currently being published.'
    author:
      required: true
      description: 'The name of the author.'
    author_url:
      description: 'URL of the author page.'
    db:
      description: 'Path to the database, default to "~/.medium_post"'
      default: "#{require('os').homedir()}/.medium_post"

try
  params = app.parse()
  if command = app.helping(params)
    return process.stderr.write app.help command
catch err
  process.stderr.write "#{err.message}\n\n"
  process.stderr.write app.help()

config = require('./config')(params.db)

ask = (question) ->
  new Promise (resolve) ->
    readline = require 'readline'
    rl = readline.createInterface
      input: process.stdin
      output: process.stdout
    rl.question "#{question}: ", (answer) ->
      rl.close()
      resolve answer

conf_init = (config) ->
  # Note, we shall be able to use integration token as well, just not tested yet
  unless config.get ['medium']
    process.stdout.write """
    Please register your application token
    From the Medium > Settings > Developers > Manage applications
    Create a new application and report below the requested informations.
    
    """
  clientId = config.get ['medium', 'clientId']
  unless clientId
    clientId = await ask 'Medium client ID'
    config.set ['medium', 'clientId'], clientId
  clientSecret = config.get ['medium', 'clientSecret']
  unless clientSecret
    clientSecret = await ask 'Medium client secret'
    config.set ['medium', 'clientSecret'], clientSecret
  redirectURL = config.get ['medium', 'redirectURL']
  unless redirectURL
    redirectURL = await ask 'Medium redirect URL'
    config.set ['medium', 'redirectURL'], redirectURL

medium_get_refresh_token = (client, config) ->
  redirectURL = config.get ['medium', 'redirectURL']
  new Promise (resolve) ->
    url = client.getAuthorizationUrl 'secretState', redirectURL, [
      medium.Scope.BASIC_PROFILE, medium.Scope.PUBLISH_POST
    ]
    process.stdout.write 'Copy the url in your browser and '
    process.stdout.write 'paste the code in the redirect URL\n'
    process.stdout.write "#{url}\n"
    resolve await ask 'Secret'

medium_exchange_access_token = (client, config, refresh_token) ->
  redirectURL = config.get ['medium', 'redirectURL']
  new Promise (resolve, reject) ->
    client.exchangeAuthorizationCode refresh_token, redirectURL,
      (err, access_token) ->
        if err
        then reject err
        else resolve access_token

get_article = (source) ->
  vfile = require 'to-vfile'
  report = require 'vfile-reporter'
  unified = require 'unified'
  doc = require 'rehype-document'
  parse = require 'remark-parse'
  remark2rehype = require 'remark-rehype'
  stringify = require 'remark-stringify'
  frontmatter = require 'remark-frontmatter'
  metadata = require 'remark-metadata'
  format = require 'rehype-format'
  html = require 'rehype-stringify'
  yaml = require 'js-yaml'
  meta = null
  new Promise (resolve, reject) ->
    unified()
    .use(parse)
    .use(frontmatter, ['yaml'])
    .use -> (ast) ->
      # Extract frontmatter
      for child in ast.children
        continue unless child.type is 'yaml'
        meta = yaml.safeLoad child.value
      # Validate article
      unless meta.lang in ['en', 'fr']
        return callback Error 'Invalid Source: lang is invalid'
      # Add source information
      ast.children.push
        type: 'paragraph'
        children: [
          type: 'text'
          value: switch meta.lang
            when 'en' then 'This article was originally published by '
            when 'fr' then 'Cet article a été publié à l\'origine par '
        ,
          type: 'link'
          url: params.url
          children: [
            type: 'text'
            value: switch meta.lang
              when 'en' then 'Adaltas'
              when 'fr' then 'Adaltas'
          ]
        ,
          type: 'text'
          value: switch meta.lang
            when 'en' then ' and was written by '
            when 'fr' then ' et fut rédigé par '
        ,
          type: 'link'
          url: "http://www.adaltas.com/#{meta.lang}/author/#{meta.author}/"
          children: [
            type: 'text'
            value: params.author
          ]
        ,
          type: 'text'
          value: '.'
        ]
      null
    .use(remark2rehype)
    .use(doc)
    .use(format)
    .use(html)
    .process vfile.readSync(source), (err, file) ->
      return reject err if err
      file.meta = meta
      resolve file

medium_post_article = (client, article) ->
  throw Error 'Required Property: article.meta.title' unless article.meta.title
  throw Error 'Required Property: article.contents' unless article.contents
  new Promise (resolve, reject) ->
    client.getUser (err, user) ->
      return reject err if err
      client.createPost
        userId: user.id
        title: article.meta.title
        contentFormat: medium.PostContentFormat.HTML
        content: article.contents
        publishStatus: medium.PostPublishStatus.DRAFT
        canonicalUrl: params.url
        tags: article.meta.tags
      , (err, post) ->
        if err
        then reject err
        else resolve post

main = ->
  try
    conf = await config.load()
    await conf_init config
    # Initialise the Medium client
    client = new medium.MediumClient
      clientId: config.get ['medium', 'clientId']
      clientSecret: config.get ['medium', 'clientSecret']
    token = config.get ['token']
    # Create or renew the authorization token
    if not token or not token.access_token or token.expires_at > Date.now
      process.stdout.write "Token expired since #{token.expires_at}\n"
      process.stdout.write 'Trying to get a new refresh token\n'
      # Get a temporary token
      code = await medium_get_refresh_token client, config
      process.stdout.write 'Refresh token is #{code}\n'
      process.stdout.write 'Trying to get a new access token\n'
      # Convert it to an authorization token
      token = await medium_exchange_access_token client, config, code
      process.stdout.write 'Access token is #{token}\n'
      # Persist the token data
      config.set 'token', token
    else
      client.setAccessToken conf.token.access_token
    # Generate article
    article = await get_article params.source
    # Post article
    post = await medium_post_article client, article
    # Print user feedback
    process.stdout.write 'Article was successfull posted as draft:'
    process.stdout.write '\n\n'
    process.stdout.write JSON.stringify post, null, '  '
    process.stdout.write '\n\n'
  catch err
    # Note:
    # * 6003 - Token was invalid
    # The refresh token and expiration date are good but for some reason the
    # access token is invalid. Solution is to remove the access token from
    # "~/.medium_post"
    process.stderr.write "Uncatched error: #{err.code} - #{err.message}\n"
    process.exit 1
main()
