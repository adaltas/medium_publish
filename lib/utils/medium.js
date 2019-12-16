// Generated by CoffeeScript 2.4.1
var ask, medium;

medium = require('medium-sdk');

ask = require('./ask');

module.exports = {
  get_refresh_token: function(client, config) {
    var redirectURL;
    redirectURL = config.get(['medium', 'redirectURL']);
    return new Promise(async function(resolve) {
      var url;
      url = client.getAuthorizationUrl('secretState', redirectURL, [medium.Scope.BASIC_PROFILE, medium.Scope.PUBLISH_POST]);
      process.stdout.write('Copy the url in your browser and ');
      process.stdout.write('paste the code in the redirect URL\n');
      process.stdout.write(`${url}\n`);
      return resolve((await ask('Secret')));
    });
  },
  exchange_access_token: function(client, config, refresh_token) {
    var redirectURL;
    redirectURL = config.get(['medium', 'redirectURL']);
    return new Promise(function(resolve, reject) {
      return client.exchangeAuthorizationCode(refresh_token, redirectURL, function(err, access_token) {
        if (err) {
          return reject(err);
        } else {
          return resolve(access_token);
        }
      });
    });
  },
  post_article: function(client, params, article) {
    if (!article.frontmatter.title) {
      throw Error('Required Property: article.frontmatter.title');
    }
    if (!article.contents) {
      throw Error('Required Property: article.contents');
    }
    return new Promise(function(resolve, reject) {
      return client.getUser(function(err, user) {
        if (err) {
          return reject(err);
        }
        return client.createPost({
          userId: user.id,
          title: article.frontmatter.title,
          contentFormat: medium.PostContentFormat.HTML,
          content: article.contents,
          publishStatus: medium.PostPublishStatus.DRAFT,
          canonicalUrl: params.url,
          tags: article.frontmatter.tags
        }, function(err, post) {
          if (err) {
            return reject(err);
          } else {
            return resolve(post);
          }
        });
      });
    });
  }
};