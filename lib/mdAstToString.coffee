
unified = require 'unified'
stringify = require 'remark-stringify'

module.exports = (ast, settings) ->
  unified()
  .use(stringify)
  .data('settings', settings || {})
  .stringify(ast)
