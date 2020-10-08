
toText = require 'hast-util-to-text'

###
Normalize absolute link
###

module.exports = ->
  (ast, vfile) ->
    return if vfile.frontmatter?.noTitleToFrontmatter
    return unless ast.children.length
    index = 0
    index++ if ast.children[0].type is 'yaml'
    child = ast.children[index]
    if child.type is 'heading' and child.depth is 1
      vfile.frontmatter ?= {}
      unless vfile.frontmatter.title
        vfile.frontmatter.title = toText child
      ast.children.splice index, 1
    null
