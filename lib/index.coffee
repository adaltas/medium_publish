medium = require 'medium-sdk'
md_to_html = require './urils/md_to_html'
ask = require './utils/ask'

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

medium_post_article = (client, params, article) ->
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

module.exports = (config, params, plugins) ->
  try
    await config.load()
    # Initialise the Medium client
    client = new medium.MediumClient
      clientId: config.get ['medium', 'clientId']
      clientSecret: config.get ['medium', 'clientSecret']
    token = config.get ['token']
    # Create or renew the authorization token
    if not token or not token.access_token or token.expires_at > Date.now
      process.stdout.write "Token expired since #{token.expires_at}\n" if token
      process.stdout.write 'Trying to get a new refresh token\n'
      # Get a temporary token
      code = await medium_get_refresh_token client, config
      process.stdout.write 'Refresh token is #{code}\n'
      process.stdout.write 'Trying to get a new access token\n'
      # Convert it to an authorization token
      token = await medium_exchange_access_token client, config, code
      process.stdout.write "Access token is #{token}\n"
      # Persist the token data
      config.set 'token', token
    else
      client.setAccessToken token.access_token
    # Generate article
    article = await md_to_html plugins, source
    # Post article
    post = await medium_post_article client, params, article
    # Print user feedback
    process.stdout.write 'Article was successfull posted as draft:'
    process.stdout.write '\n\n'
    process.stdout.write JSON.stringify post, null, '  '
    process.stdout.write '\n\n'
  catch err
    ### Note:
    # 6003 - Token was invalid
    The refresh token and expiration date are good but for some reason the
    access token is invalid. Solution is to remove the access token from
    "~/.medium_post"
    Happened:
    somewhere in june (see git log)
    sep 9, 2019
    nov 18, 2019: Uncatched error: 6000 - Access token is invalid.
    ###
    process.stderr.write "Uncatched error: #{err.code} - #{err.stack || err.message}\n"
    process.exit 1
