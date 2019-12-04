
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
    langs:
      description: 'Accepted languages'
      type: 'array'
      default: []

try
  params = app.parse()
  if command = app.helping(params)
    return process.stderr.write app.help command
catch err
  process.stderr.write "#{err.message}\n\n"
  process.stderr.write app.help()
  return

( ->
  try
    config = require('./config')(params.db)
    await config.load()
    await config.init() if process.stdin.isTTY
    plugins = [
      plugin: require './plugins/parse_frontmatter'
    ,
      plugin: require './plugins/normalize_links'
      settings:
        baseURL: config.get ['user', 'baseURL']
    ,
      plugin: require './plugins/table_to_code'
    ,
      plugin: require './plugins/validate_lang'
      settings:
        langs: params.langs
    ,
      plugin: require './plugins/append_source'
      settings:
        url: params.url
        author: params.author
        authorUrl: params.author_url
    ]
    require('.')(config, params, plugins)
  catch err
    process.stderr.write "\n#{err.stack}\n\n"
)()
