
unified = require 'unified'
parseMarkdown = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
extractFrontmatter = require 'remark-frontmatter'
pluginParseFrontmatter = require '../../src/Plugins/parse_frontmatter'
pluginExtractTitle = require '../../src/Plugins/extract_title'

describe 'Extract title', ->
  
  it 'without frontmatter', ->
    {frontmatter} = await unified()
    .use parseMarkdown
    .use extractFrontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use pluginExtractTitle
    .use remark2rehype
    .use html
    .process """
    # My title
    """
    frontmatter.should.eql
      title: 'My title'
  
  it 'with frontmatter', ->
    {frontmatter} = await unified()
    .use parseMarkdown
    .use extractFrontmatter, ['yaml']
    .use pluginParseFrontmatter
    .use pluginExtractTitle
    .use remark2rehype
    .use html
    .process """
    ---
    lang: fr
    ---
    
    # My title
    """
    frontmatter.should.eql
      lang: 'fr'
      title: 'My title'
    
