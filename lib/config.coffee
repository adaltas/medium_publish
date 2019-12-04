
fs = require 'fs'
yaml = require 'js-yaml'

module.exports = (target) ->
  store = null
  init: ->
    # Note, we shall be able to use integration token as well, just not tested yet
    unless this.get ['medium']
      process.stdout.write """
      Please register your application token
      From the Medium > Settings > Developers > Manage applications
      Create a new application and report below the requested informations.
      
      """
    clientId = this.get ['medium', 'clientId']
    unless clientId
      clientId = await ask 'Medium client ID'
      this.set ['medium', 'clientId'], clientId
    clientSecret = this.get ['medium', 'clientSecret']
    unless clientSecret
      clientSecret = await ask 'Medium client secret'
      this.set ['medium', 'clientSecret'], clientSecret
    redirectURL = this.get ['medium', 'redirectURL']
    unless redirectURL
      redirectURL = await ask 'Medium redirect URL (must match the application callback URL)'
      this.set ['medium', 'redirectURL'], redirectURL
    baseURL = this.get ['user', 'baseURL']
    unless baseURL
      baseURL = await ask 'Base URL for absolute links'
      this.set ['user', 'baseURL'], baseURL
    langs = this.get ['user', 'langs']
    unless langs
      langs = await ask 'Supported languages separated by commas'
      this.set ['user', 'langs'], langs.split(',').map (lang) -> lang.trim()
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
    throw Error 'Config Not Loaded: database must be loaded before accessing data' unless store?
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
