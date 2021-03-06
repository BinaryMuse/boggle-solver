// Generated by CoffeeScript 1.6.3
var Trie,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Trie = (function() {
  Trie.MATCH = 1;

  Trie.NO_MATCH = 2;

  Trie.PARTIAL_MATCH = 3;

  function Trie(data) {
    this.data = data != null ? data : {};
    this.find = __bind(this.find, this);
    this.put = __bind(this.put, this);
  }

  Trie.prototype.put = function(word, trie) {
    var first;
    if (trie == null) {
      trie = this.data;
    }
    first = word[0];
    if (word.length === 1) {
      if (trie[first]) {
        return trie[first]._ = 1;
      } else {
        return trie[first] = 1;
      }
    } else {
      if (trie[first] === 1) {
        trie[first] = {
          _: 1
        };
        return this.put(word.slice(1, word.length), trie[first]);
      } else {
        if (trie[first] == null) {
          trie[first] = {};
        }
        return this.put(word.slice(1, word.length), trie[first]);
      }
    }
  };

  Trie.prototype.find = function(word, trie) {
    var first;
    if (trie == null) {
      trie = this.data;
    }
    first = word[0];
    if (word.length === 1) {
      if ((typeof trie[first] === 'object' && trie[first]._) || trie[first] === 1) {
        return Trie.MATCH;
      } else if (typeof trie[first] === 'object') {
        return Trie.PARTIAL_MATCH;
      } else {
        return Trie.NO_MATCH;
      }
    } else {
      return this.find(word.slice(1, word.length), trie[first]);
    }
  };

  return Trie;

})();

module.exports = Trie;
