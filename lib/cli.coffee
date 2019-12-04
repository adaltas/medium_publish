
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
  return

( ->
  try
    config = require('./config')(params.db)
    await config.load()
    await config.init() if process.stdin.isTTY
    require('.')(config, params)
  catch err
    process.stderr.write "\n#{err.stack}\n\n"
)()
