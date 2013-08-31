class Traverser
  constructor: (@minWordLength, @grid, @trie) ->
    @completionCallbacks = []

  onComplete: (callback) ->
    @completionCallbacks.push(callback)

  # `callback` is called when a word is found in the grid and takes two
  # parameters: the word found and a list of grid positions used to find the word.
  search: (callback) =>
    for row in [0..4]
      for col in [0..4]
        do (row, col) =>
          @traverse([[row, col]], callback)
    cb() for cb in @completionCallbacks

  traverse: (explored, callback) =>
    last = explored[explored.length - 1]
    letters = (@grid[tile[0]][tile[1]] for tile in explored)
    word = letters.join('')
    match = @trie.find(word)

    if match == Trie.MATCH && explored.length >= @minWordLength
      callback(word, explored)

    # Bail early on traversing the graph if Trie.find returned NO_MATCH.
    # This optomization allows us to skip most of the grid, and cut traversal
    # time from minutes to milliseconds.
    if match != Trie.NO_MATCH
      adj = @adjacentCells(last[0], last[1])
      adj = adj.filter (pair) => !@visited(pair, explored)
      if adj.length > 0
        for sq in adj
          newExplored = explored.concat([[ sq[0], sq[1] ]])
          @traverse(newExplored, callback)

  adjacentCells: (row, col) =>
    adj = []
    for r in [row - 1, row, row + 1]
      continue if r < 0 || r > 4
      for c in [col - 1, col, col + 1]
        continue if c < 0 || c > 4
        adj.push([r, c]) unless r == row && c == col
    adj

  visited: (search, visited) =>
    for pair in visited
      return true if search[0] == pair[0] && search[1] == pair[1]
    false
