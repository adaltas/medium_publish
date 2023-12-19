
import unified from 'unified'
import parseMarkdown from 'remark-parse'
import remark2rehype from 'remark-rehype'
import html from 'rehype-stringify'
import frontmatter from 'remark-frontmatter'
import format from 'rehype-format'
import pluginParseFrontmatter from 'remark-read-frontmatter'
import pluginAppendSource from 'medium_publish/plugins/append_source'

describe 'Append source and author information', ->
  
  it 'simple', ->
    {contents} = await unified()
    .use parseMarkdown
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
    .use parseMarkdown
    .use frontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use pluginAppendSource,
      url: 'http://www.adaltas.com'
      author: 'myself'
      authorUrl: (ast, {data: {lang}}) ->
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
    
