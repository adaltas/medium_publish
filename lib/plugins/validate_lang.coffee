
module.exports = ->
  (ast, vfile) ->
    # Validate article
    unless vfile.frontmatter.lang in ['en', 'fr']
      throw Error 'Invalid Source: lang is invalid'
    null
    
