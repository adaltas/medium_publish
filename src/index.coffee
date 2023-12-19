import medium from 'medium-sdk'
import md_to_html from 'medium_publish/utils/md_to_html'
import {get_refresh_token, exchange_access_token, post_article} from 'medium_publish/utils/medium'

export default (config, params, plugins) ->
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
      code = await get_refresh_token client, config
      process.stdout.write "Refresh token is #{code}\n"
      process.stdout.write 'Trying to get a new access token\n'
      # Convert it to an authorization token
      token = await exchange_access_token client, config, code
      process.stdout.write "Access token is #{token.access_token}\n"
      # Persist the token data
      config.set 'token', token
    else
      client.setAccessToken token.access_token
    # Load the plugins
    plugins = plugins.map (plugin) ->
      if typeof plugin is 'string'
      then require.main.require plugin
      else plugin
    # Generate article
    article = await md_to_html plugins, params.source
    # Post article
    post = await post_article client, params, article
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
    "~/.medium_publish"
    Happened:
    somewhere in june (see git log)
    sep 9, 2019
    nov 18, 2019: Uncatched error: 6000 - Access token is invalid.
    jan 22, 2020: Uncatched error: 6000 - Access token is invalid.
    apr 13, 2022: Uncatched error: 6001 - Access token expired.
    jun 22, 2022: Uncatched error: 6000 - Access token is invalid
    ###
    if err.code is 6000 or err.code is 6001
      await config.backup()
      await config.set ['token', 'access_token'], null
      process.stdout.write "Token expired."
      process.stdout.write "Previous access token was erased from configuration."
      process.stdout.write "Please run this command again."
      process.stdout.write '\n\n'
      process.exit 6
      return
    process.stderr.write "Uncatched error: #{err.code} - #{err.stack || err.message}\n\n"
    process.exit 1
