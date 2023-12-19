
export default (settings) ->
  settings.langs ?= []
  (ast, vfile) ->
    return unless settings.langs.length
    # Validate article
    unless vfile.data.lang in settings.langs
      throw Error 'Invalid Source: lang is invalid'
    null
    
