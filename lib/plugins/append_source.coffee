
path = require 'path'

module.exports = (settings={})->
  throw Error 'Invalid Settings: missing the `url` field' unless settings.url
  throw Error 'Invalid Settings: missing the `author` field' unless settings.author
  throw Error 'Invalid Settings: missing the `authorUrl` field' unless settings.authorUrl
  (ast, vfile) ->
    if typeof settings.authorUrl is 'function'
      settings.authorUrl = settings.authorUrl.call null, ast, vfile
    throw Error "Invalid authorUrl: expect a string, got #{settings.authorUrl}" unless typeof settings.authorUrl is 'string'
    # Add source information
    ast.children.push
      type: 'paragraph'
      children: [
        type: 'text'
        value: switch vfile.frontmatter.lang
          when 'en' then 'This article was originally published by '
          when 'fr' then 'Cet article a été publié à l\'origine par '
      ,
        type: 'link'
        url: settings.url
        children: [
          type: 'text'
          value: switch vfile.frontmatter.lang
            when 'en' then 'Adaltas'
            when 'fr' then 'Adaltas'
        ]
      ,
        type: 'text'
        value: switch vfile.frontmatter.lang
          when 'en' then ' and was written by '
          when 'fr' then ' et fut rédigé par '
      ,
        type: 'link'
        url: settings.authorUrl
        children: [
          type: 'text'
          value: settings.author
        ]
      ,
        type: 'text'
        value: '.'
      ]
    null
    
