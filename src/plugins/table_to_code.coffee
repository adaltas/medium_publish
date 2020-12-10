
visit = require 'unist-util-visit'
md_ast_to_string = require '../utils/md_ast_to_string'

module.exports = ->
  (tree, file) ->
    visit tree, 'table', (node) ->
      value = md_ast_to_string node
      node.type = 'code'
      node.lang = null
      node.meta = null
      node.value = value.trim()
      node.children = null
      return null
