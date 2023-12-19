
import {unified} from 'unified'
import parseMarkdown from 'remark-parse'
import remark2rehype from 'remark-rehype'
import html from 'rehype-stringify'
import frontmatter from 'remark-frontmatter'
import pluginParseFrontmatter from 'remark-read-frontmatter'

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
    
