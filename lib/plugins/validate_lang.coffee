
module.exports = (settings) ->
  settings.langs ?= []
  (ast, vfile) ->
    return unless settings.langs.length
    # Validate article
    unless vfile.frontmatter.lang in settings.langs
      throw Error 'Invalid Source: lang is invalid'
    null
    
