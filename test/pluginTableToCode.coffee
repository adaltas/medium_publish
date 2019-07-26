
unified = require 'unified'
parse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
pluginTableToCode = require '../lib/pluginTableToCode'

describe 'Markdown table to AST', ->
  
  it 'simple', ->
    {contents} = await unified()
    .use parse
    .use pluginTableToCode
    .use remark2rehype
    .use html
    .process """
    | a | b |
    |---|---|
    | a | b |
    """
    contents.should.eql """
    <pre><code>| a   | b   |
    | --- | --- |
    | a   | b   |
    </code></pre>
    """
    
