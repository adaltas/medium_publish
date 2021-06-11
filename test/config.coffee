
os = require 'os'
path = require 'path'
config = require '../src/config'

describe 'Config', ->
  
  it 'set', ->
    target = path.join(os.tmpdir(), './medium_publish_config')
    conf = config target
    await conf.load()
    conf.set 'a_key', 'a value'
    val = conf.get 'a_key'
    val.should.eql 'a value'
