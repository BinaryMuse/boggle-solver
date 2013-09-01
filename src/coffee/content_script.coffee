statusText = null
wordText   = null

jQuery ->
  return unless $("#board td").length

  statusText = $("<p>").css(position: 'absolute', left: '600px', top: '60px').appendTo('body')
  wordText   = $("<h1>").css(position: 'absolute', left: '600px', top: '70px').appendTo('body')

  # UI elements for solver control
  controls = $("<div>").css(position: 'absolute', top: '70px', left: '600px')
  addControl = (elems...) ->
    container = $("<div>")
    container.append(elem) for elem in elems
    controls.append(container)

  # The computer can continue to solve the game even after the game is over
  # because the game grid is only hidden via CSS.
  stopOnGameOver = true
  radio1 = $("<input>").attr('type', 'radio').attr('name', 'solveMode').attr('value', 'true')
    .attr('checked', 'checked')
  radio2 = $("<input>").attr('type', 'radio').attr('name', 'solveMode').attr('value', 'false')

  radio1.attr('id', 'sogo').on 'change', -> stopOnGameOver = true if $(this).val() == 'true'
  radio2.attr('id', 'cogo').on 'change', -> stopOnGameOver = false if $(this).val() == 'false'

  button = $("<button>")
  button.text('solve')
  button.on 'click', ->
    controls.remove()
    solve(stopOnGameOver)

  addControl button
  addControl radio1, $("<label>").attr('for', 'sogo').css('font-size', '12pt').text("Stop on Game Over")
  addControl radio2, $("<label>").attr('for', 'cogo').css('font-size', '12pt').text("Continue on Game Over")

  showControls = ->
    if $("#board:visible").length
      controls.appendTo('body')
    else
      setTimeout showControls, 500

  showControls()

solve = (stopOnGameOver) ->
  words = []
  setStatus("scanning...")

  xhr = new XMLHttpRequest()
  xhr.open 'GET', chrome.runtime.getURL('src/json/data.json')
  xhr.onreadystatechange = ->
    if xhr.readyState == 4 && xhr.status == 200
      data = JSON.parse(xhr.responseText)
      traverser = new Traverser(3, getGrid(), new Trie(data))
      traverser.onComplete ->
        postWords(words, stopOnGameOver)
      traverser.search (word, positions) ->
        setWord(word)
        words.push(word: word, positions: positions)

  xhr.send()

# `postWords` only deals with logic and defers to
# external functions for all DOM manipulation and querying.
postWords = (words, stopOnGameOver) ->
  setStatus("submitting...")
  setWord("")
  usedWords = alreadyPlayedWords()
  sortedWords = words.sort (a, b) -> b.word.length - a.word.length

  done = ->
    setStatus("done")
    setWord("")

  postNextWord = ->
    # Try again in a moment if we're still waiting on the last submit to finish
    if wordSubmissionPending()
      return setTimeout(postNextWord, 0)

    if sortedWords.length
      word = sortedWords.shift()
      return postNextWord() if word.word in usedWords
      usedWords.push word.word
      setWord(word.word)

      selectGridTiles word.positions

      # If we've been told not to cheat, make sure the button is still visible
      if stopOnGameOver == false || gameIsActive()
        submitCurrentWord()
      else
        done()

      setTimeout postNextWord, 0
    else
      done()

  postNextWord()

setStatus = (status) ->
  statusText.text(status)

setWord = (word) ->
  wordText.text(word)

getGrid = ->
  tiles = $("#board td").map (idx, td) -> $(td).text().trim().toLowerCase()
  tiles = tiles.toArray()

  [
    tiles[0..4]
    tiles[5..9]
    tiles[10..14]
    tiles[15..19]
    tiles[20..24]
  ]

selectGridTiles = (tiles) ->
  cellIndexes = tiles.map (pos) ->
    [row, col] = pos
    row * 5 + col

  $($("#board td").get(index)).click() for index in cellIndexes

submitCurrentWord = ->
  $("form input[type=submit]").get(0).click()

wordSubmissionPending = ->
  $("form input[type=submit]").attr('disabled')

gameIsActive = ->
  $("#board:visible").length

alreadyPlayedWords = ->
  historyRows = $($("#history tr td:first-child")).toArray()
  historyRows = historyRows[0...historyRows.length - 1]
  usedWords = historyRows.map (td) -> $(td).text()
