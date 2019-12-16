// Generated by CoffeeScript 2.4.1
var ask, fs, yaml;

fs = require('fs');

yaml = require('js-yaml');

ask = require('./utils/ask');

module.exports = function(target) {
  var store;
  store = null;
  return {
    init: async function() {
      var baseURL, clientId, clientSecret, langs, redirectURL;
      // Note, we shall be able to use integration token as well, just not tested yet
      if (!this.get(['medium'])) {
        process.stdout.write("Please register your application token\nFrom the Medium > Settings > Developers > Manage applications\nCreate a new application and report below the requested informations.\n");
      }
      clientId = this.get(['medium', 'clientId']);
      if (!clientId) {
        clientId = (await ask('Medium client ID'));
        this.set(['medium', 'clientId'], clientId);
      }
      clientSecret = this.get(['medium', 'clientSecret']);
      if (!clientSecret) {
        clientSecret = (await ask('Medium client secret'));
        this.set(['medium', 'clientSecret'], clientSecret);
      }
      redirectURL = this.get(['medium', 'redirectURL']);
      if (!redirectURL) {
        redirectURL = (await ask('Medium redirect URL (must match the application callback URL)'));
        this.set(['medium', 'redirectURL'], redirectURL);
      }
      baseURL = this.get(['user', 'baseURL']);
      if (!baseURL) {
        baseURL = (await ask('Base URL for absolute links'));
        this.set(['user', 'baseURL'], baseURL);
      }
      langs = this.get(['user', 'langs']);
      if (!langs) {
        langs = (await ask('Supported languages separated by commas'));
        return this.set(['user', 'langs'], langs.split(',').map(function(lang) {
          return lang.trim();
        }));
      }
    },
    load: async function() {
      var data, err, stat;
      try {
        stat = (await fs.promises.stat(target));
      } catch (error) {
        err = error;
        if (err.code !== 'ENOENT') {
          throw err;
        }
        await fs.promises.writeFile(target, yaml.safeDump({}));
      }
      data = (await fs.promises.readFile(target));
      data = yaml.safeLoad(data.toString());
      return store = data;
    },
    get: function(key) {
      var i, k, len, val;
      if (store == null) {
        throw Error('Config Not Loaded: database must be loaded before accessing data');
      }
      if (typeof key === 'string') {
        key = [key];
      }
      val = store;
      for (i = 0, len = key.length; i < len; i++) {
        k = key[i];
        if (val[k] == null) {
          return val[k];
        }
        val = val[k];
      }
      return val;
    },
    set: async function(key, value) {
      var data, i, k, len, ref;
      if (store == null) {
        throw Error('Data Not Loaded');
      }
      if (typeof key === 'string') {
        key = [key];
      }
      data = store;
      ref = key.slice(0, -1);
      for (i = 0, len = ref.length; i < len; i++) {
        k = ref[i];
        data = data[k] != null ? data[k] : data[k] = {};
      }
      k = key.slice(-1);
      data[k] = value;
      data = yaml.safeDump(store);
      await fs.promises.writeFile(target, data);
      return this;
    }
  };
};