"use strict"

{goto} = window.APP_LIB.navigation
{mpd} = window.MPD_APP


stack = []
chainTimer = null
CHAIN_TIMEOUT = 400


# Navigation for g+... chains.
key 'g', 'not-input', ->
  return true if stack.length isnt 0

  stack.push 'g'
  chainTimer = setTimeout ->
    stack.length = 0
    chainTimer = null
  , CHAIN_TIMEOUT
  false

# Helper method for g+... chains.
g = (path) ->
  return true if stack.length isnt 1 or stack[0] isnt 'g'

  if chainTimer?
    clearTimeout chainTimer
    chainTimer = null
    stack.length = 0
    goto path

# g+n -> Now Playing
key 'n', 'not-input', -> g('/now_playing')

# g+f -> File Browser
key 'f', 'not-input', -> g('/file_browser')


# Let the app handle soft refreshes.
key 'f5, ctrl+r', ->
  document.dispatchEvent new CustomEvent('navigation:page')
  false

# 'u' updates the music database.
key 'u', 'not-input', ->
  mpd 'update', (err, data) ->
    console.error(err) if err
  false

# '/' focusses the search input.
key '/', 'not-input', ->
  search = document.getElementById 'search'
  search.focus() if search
  false

# 'escape' removes focus from input elements.
key 'escape', 'input', (event) ->
  event.target.blur()
  false
