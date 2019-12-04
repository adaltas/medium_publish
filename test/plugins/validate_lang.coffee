
require 'should'
unified = require 'unified'
parse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
frontmatter = require 'remark-frontmatter'
pluginParseFrontmatter = require '../../lib/Plugins/parse_frontmatter'

describe 'Markdown validate lang', ->
  
  it 'simple', ->
    {frontmatter} = await unified()
    .use parse
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
    
