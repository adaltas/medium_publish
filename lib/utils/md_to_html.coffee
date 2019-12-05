
vfile = require 'to-vfile'
unified = require 'unified'
doc = require 'rehype-document'
parse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
frontmatter = require 'remark-frontmatter'
format = require 'rehype-format'
html = require 'rehype-stringify'

module.exports = (plugins, source) ->
  new Promise (resolve, reject) ->
    u = unified()
    u.use parse
    u.use frontmatter, ['yaml']
    u.use plugin, settings for {plugin, settings} in plugins
    u.use remark2rehype
    u.use doc
    u.use format
    u.use html
    u.process vfile.readSync(source), (err, file) ->
      return reject err if err
      resolve file
