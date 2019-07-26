
require 'should'
unified = require 'unified'
parse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
frontmatter = require 'remark-frontmatter'
format = require 'rehype-format'
pluginParseFrontmatter = require '../lib/pluginParseFrontmatter'
pluginAppendSource = require '../lib/pluginAppendSource'

describe 'Append source and author information', ->
  
  it 'simple', ->
    {contents} = await unified()
    .use parse
    .use frontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use pluginAppendSource,
      url: 'http://www.adaltas.com'
      author: 'myself'
      authorUrl: 'http://www.adaltas.com/author/myself/'
    .use remark2rehype
    .use format
    .use html
    .process """
    ---
    lang: en
    ---
    
    Article content.
    """
    contents.trim().should.eql """
    <p>Article content.</p>
    <p>This article was originally published by <a href="http://www.adaltas.com">Adaltas</a> and was written by <a href="http://www.adaltas.com/author/myself/">myself</a>.</p>
    """
      
  it 'authorUrl as a function', ->
    {contents} = await unified()
    .use parse
    .use frontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use pluginAppendSource,
      url: 'http://www.adaltas.com'
      author: 'myself'
      authorUrl: (lang) ->
        lang.should.eql 'en'
        'http://www.adaltas.com/author/myself/'
    .use remark2rehype
    .use format
    .use html
    .process """
    ---
    lang: en
    ---
    
    Article content.
    """
    contents.trim().should.eql """
    <p>Article content.</p>
    <p>This article was originally published by <a href="http://www.adaltas.com">Adaltas</a> and was written by <a href="http://www.adaltas.com/author/myself/">myself</a>.</p>
    """
    
