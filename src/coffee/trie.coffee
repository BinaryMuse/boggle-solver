class Trie
  @MATCH = 1
  @NO_MATCH = 2
  @PARTIAL_MATCH = 3

  constructor: (@data = {}) ->

  put: (word, trie) =>
    trie ?= @data
    first = word[0]
    if word.length == 1
      if trie[first]
        trie[first]._ = 1
      else
        trie[first] = 1
    else
      if trie[first] == 1
        trie[first] = { _: 1 }
        @put(word[1...word.length], trie[first])
      else
        trie[first] ?= {}
        @put(word[1...word.length], trie[first])

  # `find` returns MATCH, NO_MATCH, or PARTIAL_MATCH so that
  # we can bail early on a graph traversal if there's no hope
  # that any descendant of the current iteration will eventually
  # result in a MATCH.
  find: (word, trie) =>
    trie ?= @data
    first = word[0]
    if word.length == 1
      if (typeof trie[first] == 'object' && trie[first]._) || trie[first] == 1
        Trie.MATCH
      else if typeof trie[first] == 'object'
        Trie.PARTIAL_MATCH
      else
        Trie.NO_MATCH
    else
      @find(word[1...word.length], trie[first])

module.exports = Trie
