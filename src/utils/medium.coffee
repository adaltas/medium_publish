
medium = require 'medium-sdk'
ask = require './ask'

module.exports =
  get_refresh_token: (client, config) ->
    redirectURL = config.get ['medium', 'redirectURL']
    new Promise (resolve) ->
      url = client.getAuthorizationUrl 'secretState', redirectURL, [
        medium.Scope.BASIC_PROFILE, medium.Scope.PUBLISH_POST,
        # uploadImage scope is subject to Medium agreement
      ]
      process.stdout.write 'Copy the url in your browser and '
      process.stdout.write 'paste the code in the redirect URL\n'
      process.stdout.write "#{url}\n"
      resolve await ask 'Secret'
  exchange_access_token: (client, config, refresh_token) ->
    redirectURL = config.get ['medium', 'redirectURL']
    new Promise (resolve, reject) ->
      client.exchangeAuthorizationCode refresh_token, redirectURL,
        (err, access_token) ->
          if err
          then reject err
          else resolve access_token
  post_article: (client, params, article) ->
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
