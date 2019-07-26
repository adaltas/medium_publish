
path = require 'path'
visit = require 'unist-util-visit'
mdAstToString = require './mdAstToString'

###
Normalize absolute link
###

module.exports = (settings) ->
  
  (tree, file) ->
    
    # normalize_links = (node) ->
    #   if node.type is 'link' and /^\//.test node.url
    #     node.url = path.join 'http://www.adaltas.com/', node.url
    #   if node.children
    #     node.children.map (child) -> normalize_links child
    #   node
    # normalize_links ast
    visit tree, 'link', (node) ->
      if settings.baseURL and /^\//.test node.url
        node.url = path.join settings.baseURL, node.url
