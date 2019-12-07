
unified = require 'unified'
parse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
pluginNormalizeLinks = require '../../src/plugins/normalize_links'
format = require 'rehype-format'

describe 'Normalize absolute links', ->
  
  it 'simple', ->
    {contents} = await unified()
    .use parse
    .use pluginNormalizeLinks, baseURL: 'http://www.adaltas.com'
    .use remark2rehype
    .use html
    .use format
    .process """
    [HTTP link](http://www.adaltas.com/some/path/)
    [absolute link](/some/path/)
    """
    contents.trim().should.eql """
    <p>
      <a href="http://www.adaltas.com/some/path/">HTTP link</a>
      <a href="http:/www.adaltas.com/some/path/">absolute link</a>
    </p>
    """
