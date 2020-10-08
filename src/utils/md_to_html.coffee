
vfile = require 'to-vfile'
unified = require 'unified'
doc = require 'rehype-document'
markdownParse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
frontmatter = require 'remark-frontmatter'
format = require 'rehype-format'
html = require 'rehype-stringify'

module.exports = (plugins, source) ->
  await unified()
  .use markdownParse
  .use frontmatter, ['yaml']
  .use ([plugin, settings] for {plugin, settings} in plugins)
  .use remark2rehype
  .use doc
  .use format
  .use html
  .process await vfile.read source
