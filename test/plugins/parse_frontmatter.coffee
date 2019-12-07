
require 'should'
unified = require 'unified'
parse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
frontmatter = require 'remark-frontmatter'
pluginParseFrontmatter = require '../../src/plugins/parse_frontmatter'
pluginTableToCode = require '../../src/plugins/table_to_code'

describe 'Markdown table to AST', ->
  
  it 'simple', ->
    {frontmatter} = await unified()
    .use parse
    .use frontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use remark2rehype
    .use html
    .process """
    ---
    title: 'Article'
    lang: fr
    ---
    """
    frontmatter.should.eql title: 'Article', lang: 'fr'
    
