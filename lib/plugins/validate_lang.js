// Generated by CoffeeScript 2.4.1
var indexOf = [].indexOf;

module.exports = function(settings) {
  if (settings.langs == null) {
    settings.langs = [];
  }
  return function(ast, vfile) {
    var ref;
    if (!settings.langs.length) {
      return;
    }
    // Validate article
    if (ref = vfile.frontmatter.lang, indexOf.call(settings.langs, ref) < 0) {
      throw Error('Invalid Source: lang is invalid');
    }
    return null;
  };
};