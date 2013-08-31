class Trie
  @MATCH = 1
  @NO_MATCH = 2
  @PARTIAL_MATCH = 3

  constructor: (@data = {}) ->

  put: (word, trie) =>
    trie ?= @data
    if first = word[0]
      trie[first] ?= {}
      @put(word[1...word.length], trie[first])
    else
      # A key of `_` indicates the end of a word.
      trie._ = true

  # `find` returns MATCH, NO_MATCH, or PARTIAL_MATCH so that
  # we can bail early on a graph traversal if there's no hope
  # that any descendant of the current iteration will eventually
  # result in a MATCH.
  find: (word, trie) =>
    trie ?= @data
    if first = word[0]
      if subTrie = trie[first]
        @find(word[1...word.length], subTrie)
      else
        Trie.NO_MATCH
    else
      if trie._
        Trie.MATCH
      else
        # The word is not valid, but is a prefix
        # of other words in the trie.
        Trie.PARTIAL_MATCH
