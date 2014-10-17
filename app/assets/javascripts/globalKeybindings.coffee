"use strict"

{registerKeyBinding} = window.APP_LIB.keybindings
{goto} = window.APP_LIB.navigation
{mpd} = window.MPD_APP


stack = []
stackTimer = null
combiKeyBindTimeout = 400


# Navigation with g+... .
registerKeyBinding 'g', (event) ->
  if stack.length is 0
    event.detail.parent.preventDefault()
    stack.push 'g'

    stackTimer = setTimeout ->
      stack.length = 0
      stackTimer = null
    , combiKeyBindTimeout
, false


# Go to 'Now Playing'
registerKeyBinding 'n', (event) ->
  if stack.length is 1 and stack[0] is 'g'
    event.detail.parent.preventDefault()
    if stackTimer
      clearTimeout stackTimer
      stackTimer = null
    goto '/now_playing'
, false


# Go to 'File Browser'
registerKeyBinding 'f', (event) ->
  if stack.length is 1 and stack[0] is 'g'
    event.detail.parent.preventDefault()
    if stackTimer
      clearTimeout stackTimer
      stackTimer = null
    goto '/file_browser'
, false


# Let the application handle soft refreshes.
for key in ['f5', 'ctrl+r']
  registerKeyBinding key, ->
    document.dispatchEvent new CustomEvent('navigation:page')


# '/' focusses the search bar
registerKeyBinding '/', ->
  search = document.getElementById 'search'
  if search
    search.focus()


# 'u' updates the database
registerKeyBinding 'u', ->
  mpd 'update', (err, data) ->
    console.error(err) if err
