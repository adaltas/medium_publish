// Generated by CoffeeScript 2.5.1
var app, command, err, params;

params = require('./params');

app = require('shell')(params);

try {
  params = app.parse();
  if (command = app.helping(params)) {
    return process.stderr.write(app.help(command));
  }
} catch (error) {
  err = error;
  process.stderr.write(`${err.message}\n\n`);
  process.stderr.write(app.help());
  return;
}

(async function() {
  var config, plugins;
  try {
    config = require('./config')(params.db);
    await config.load();
    if (process.stdin.isTTY) {
      await config.init();
    }
    plugins = [
      {
        plugin: require('remark-read-frontmatter')
      },
      {
        plugin: require('remark-title-to-frontmatter')
      },
      {
        plugin: require('remark-absolute-links'),
        settings: {
          baseURL: config.get(['user',
      'baseURL'])
        }
      },
      {
        plugin: require('remark-table-to-code')
      },
      {
        //   plugin: require 'remark-public-images'
        // ,
        plugin: require('./plugins/validate_lang'),
        settings: {
          langs: params.langs
        }
      },
      {
        plugin: require('./plugins/append_source'),
        settings: {
          url: params.url,
          author: params.author,
          authorUrl: params.author_url
        }
      }
    ];
    return require('.')(config, params, plugins);
  } catch (error) {
    err = error;
    return process.stderr.write(`\n${err.stack}\n\n`);
  }
})();
