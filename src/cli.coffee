
import shell from 'shell'
import remarkReadFrontmatter from 'remark-read-frontmatter'
import remarkTitleToFrontmatter from 'remark-title-to-frontmatter'
import remarkAbsoluteLinks from 'remark-absolute-links'
import remarkTableToCode from 'remark-table-to-code'
import remarkValidateLang from './plugins/validate_lang'
import remarkAppendSource from './plugins/append_source'
import params_config from 'medium_publish/params'
import medium from 'medium_publish/index'
import configure from 'medium_publish/config'

app = shell(params)

try
  params = app.parse()
  if command = app.helping(params_config)
    return process.stderr.write app.help command
catch err
  process.stderr.write "#{err.message}\n\n"
  process.stderr.write app.help()
  return

try
  config = configure(params.db)
  await config.load()
  await config.init() if process.stdin.isTTY
  plugins = [
    plugin: remarkReadFrontmatter
  ,
    plugin: remarkTitleToFrontmatter
  ,
    plugin: remarkAbsoluteLinks
    settings:
      baseURL: config.get ['user', 'baseURL']
  ,
    plugin: remarkTableToCode
  ,
  #   plugin: require 'remark-public-images'
  # ,
    plugin: remarkValidateLang
    settings:
      langs: params.langs
  ,
    plugin: remarkAppendSource
    settings:
      url: params.url
      author: params.author
      authorUrl: params.author_url
  ]
  medium(config, params, plugins)
catch err
  process.stderr.write "\n#{err.stack}\n\n"
