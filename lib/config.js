// Generated by CoffeeScript 2.7.0
import fs from 'fs/promises';

import yaml from 'js-yaml';

import ask from 'medium_publish/utils/ask';

export default function(target) {
  var store;
  store = null;
  return {
    backup: async function() {
      return (await fs.copyFile(target, target + '.bck'));
    },
    init: async function() {
      var baseURL, clientId, clientSecret, langs, redirectURL;
      // Note, we shall be able to use integration token as well, just not tested yet
      if (!this.get(['medium'])) {
        process.stdout.write(`Please register your application token
From the Medium > Settings > Security and apps > Developer applications
Create a new application and report below the requested informations.
`);
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
        stat = (await fs.stat(target));
      } catch (error) {
        err = error;
        if (err.code !== 'ENOENT') {
          throw err;
        }
        await fs.writeFile(target, yaml.dump({}));
      }
      data = (await fs.readFile(target));
      data = yaml.load(data.toString());
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
      data = yaml.dump(store);
      await fs.writeFile(target, data);
      return this;
    }
  };
};
