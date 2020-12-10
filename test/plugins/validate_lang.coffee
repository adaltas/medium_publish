
unified = require 'unified'
parseMarkdown = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
frontmatter = require 'remark-frontmatter'
pluginParseFrontmatter = require '../../src/Plugins/parse_frontmatter'

describe 'Validate lang', ->
  
  it 'simple', ->
    {frontmatter} = await unified()
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
    frontmatter.should.eql lang: 'fr'
    
