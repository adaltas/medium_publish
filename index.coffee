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

config = require('./lib/config')(params.db)

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
  baseURL = config.get ['user', 'baseURL']
  unless baseURL
    redirectURL = await ask 'Base URL for absolute links'
    config.set ['user', 'baseURL'], redirectURL
  langs = config.get ['user', 'langs']
  unless baseURL
    redirectURL = await ask 'Supported languages separated by commas'
    config.set ['user', 'langs'], langs.split(',').map (lang) -> lang.trim()

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
  path = require 'path'
  pluginParseFrontmatter = require './lib/pluginParseFrontmatter'
  pluginNormalizeLinks = require './lib/pluginNormalizeLinks'
  pluginTableToCode = require './lib/pluginTableToCode'
  pluginValidateLang = require './lib/pluginValidateLang'
  pluginAppendSource = require './lib/pluginAppendSource'
  baseURL = config.get ['user', 'baseURL']
  langs = config.get ['user', 'langs']
  new Promise (resolve, reject) ->
    unified()
    .use parse
    .use frontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use pluginNormalizeLinks, baseURL: baseURL
    .use pluginTableToCode
    .use pluginValidateLang, langs
    .use pluginAppendSource,
      url: params.url
      author: params.author
      authorUrl: params.author_url || (lang) ->
        # TODO: when switting to Gasty, author url will be internationalized
        [
          "http://www.adaltas.com/"
          vfile.frontmatter.lang
          "/author/"
          vfile.frontmatter.author
          "/"
        ].join ''
    .use remark2rehype
    .use doc
    .use format
    .use html
    .process vfile.readSync(source), (err, file) ->
      return reject err if err
      resolve file

medium_post_article = (client, article) ->
  throw Error 'Required Property: article.frontmatter.title' unless article.frontmatter.title
  throw Error 'Required Property: article.contents' unless article.contents
  new Promise (resolve, reject) ->
    client.getUser (err, user) ->
      return reject err if err
      client.createPost
        userId: user.id
        title: article.frontmatter.title
        contentFormat: medium.PostContentFormat.HTML
        content: article.contents
        publishStatus: medium.PostPublishStatus.DRAFT
        canonicalUrl: params.url
        tags: article.frontmatter.tags
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
    process.stderr.write "Uncatched error: #{err.code} - #{err.stack}\n"
    process.exit 1
main()
