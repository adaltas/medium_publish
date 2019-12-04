
visit = require 'unist-util-visit'
mdAstToString = require '../utils/mdAstToString'

module.exports = ->
  (tree, file) ->
    visit tree, 'table', (node) ->
      value = mdAstToString node
      node.type = 'code'
      node.lang = null
      node.meta = null
      node.value = value
      node.children = null
      return null
