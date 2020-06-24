
yaml = require 'js-yaml'

###
Parse frontmatter and insert the "frontmatter" field in the vfile object.
###

module.exports = ->
  (ast, vfile) ->
    # Extract frontmatter
    for child in ast.children
      continue unless child.type is 'yaml'
      vfile.frontmatter = yaml.safeLoad child.value
    null
