
unified = require 'unified'
parseMarkdown = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
frontmatter = require 'remark-frontmatter'
pluginParseFrontmatter = require 'remark-read-frontmatter'

describe 'Validate lang', ->
  
  it 'simple', ->
    {data} = await unified()
    .use parseMarkdown
    .use frontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use remark2rehype
    .use html
    .process """
    ---
    lang: fr
    ---
    """
    data.should.eql lang: 'fr'
    
