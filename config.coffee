
fs = require 'fs'
yaml = require 'js-yaml'

module.exports = (target) ->
  store = null
  load: ->
    try
      stat = await fs.promises.stat target
    catch err
      throw err unless err.code is 'ENOENT'
      await fs.promises.writeFile target, yaml.safeDump {}
    data = await fs.promises.readFile target
    data = yaml.safeLoad data.toString()
    store = data
  get: (key) ->
    throw Error 'Data Not Loaded' unless store?
    key = [key] if typeof key is 'string'
    val = store
    for k in key
      return val[k] unless val[k]?
      val = val[k]
    val
  set: (key, value) ->
    throw Error 'Data Not Loaded' unless store?
    key = [key] if typeof key is 'string'
    data = store
    for k in key.slice(0, -1)
      data = data[k] ?= {}
    k = key.slice(-1)
    data[k] = value
    data = yaml.safeDump store
    await fs.promises.writeFile target, data
    @