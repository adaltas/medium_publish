
unified = require 'unified'
stringify = require 'remark-stringify'
gfm = require 'remark-gfm'

module.exports = (ast, settings) ->
  unified()
  .use stringify
  .use gfm
  .data 'settings', settings || {}
  .stringify ast
