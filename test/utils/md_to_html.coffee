
unified = require 'unified'
parse = require 'remark-parse'
remark2rehype = require 'remark-rehype'
html = require 'rehype-stringify'
md_ast_to_string = require '../../lib/utils/md_ast_to_string'

describe 'Append source and author information', ->
  
  it 'simple', ->
    {contents} = await unified()
    .use parse
    .use -> (tree, file) ->
      node = {}
      node.type = 'code'
      node.value = JSON.stringify md_ast_to_string(tree)
      node
    .use remark2rehype
    .use html
    .process 'hello'
    contents.should.eql '<pre><code>"hello\\n"\n</code></pre>'
