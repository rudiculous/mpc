"use strict"

# Initializes the application.
#
# * Creates a websocket connection.
# * Creates a function that connects to MPD.
# * Initializes the pushstate and popstate event handlers.
# * Creates an initial state.

socket = io()
app = {}

window.MPD_APP = app


# Allows you to se the title of the page.
baseTitle = document.title
Object.defineProperty app, 'title',
  get: -> document.title
  set: (newTitle) ->
    document.title =
      if newTitle
        "#{newTitle} | #{baseTitle}"
      else
        baseTitle


# Sends data to the server and waits for a response.
app.mpd = (command, args..., callback) ->
  last = arguments.length - 1

  if arguments.length < 2
    throw new Error('mpd() called with too few arguments.')

  if typeof(callback) isnt 'function'
    throw new Error('Last argument to mpd() should be a callback.')

  socket.emit 'mpd:command',
    command: command
    args: args
  , callback

  return

app.views = {}
app.views.generics = {}

app.blocks =
  navigation: document.getElementById 'navigation'
  controls: document.getElementById 'controls'
  main: document.getElementById 'main'

# Dispatch events when something has changed.
socket.on 'mpd:changed', (what) ->
  document.dispatchEvent new CustomEvent('mpd:changed',
    detail: {what: what}
  )
  document.dispatchEvent new CustomEvent("mpd:changed:#{what}")


# When navigation takes place, run the router.
router = window.APP_LIB.router
document.addEventListener 'navigation:page', router(app.blocks.main), false


# Attach handlers for page navigation.
{attachFormSubmitHandler, attachClickHandler} = window.APP_LIB.navigation
document.addEventListener 'submit', attachFormSubmitHandler, true
document.addEventListener 'click', attachClickHandler, true


# Attach handlers for key events.
{keyListener} = window.APP_LIB
document.addEventListener 'keylistener:key', (event) ->
  console.log event.detail
, false
document.addEventListener 'keypress', keyListener, true


# Delay execution of function long enough to miss the popstate event
# that is fired by some browsers on the initial page load.
#
# @todo Is this (still) necessary?
setTimeout ->
  window.addEventListener 'popstate', (event) ->
    document.dispatchEvent new CustomEvent('navigation:page')
    document.dispatchEvent new CustomEvent('state:updated')
, 500

setTimeout ->
  state = history.state

  # If no state yet, create an initial state.
  unless state
    state =
      location:
        hash: document.location.hash
        host: document.location.host
        hostname: document.location.hostname
        href: document.location.href
        origin: document.location.origin
        pathname: document.location.pathname
        port: document.location.port
        protocol: document.location.protocol
        search: document.location.search
      title: app.title
      activeTab: null

    history.replaceState(state, '', document.location.href)

  document.dispatchEvent new CustomEvent('navigation:page')
  document.dispatchEvent new CustomEvent('state:updated')
, 0


# Updates the global state.
app.updateState = (newState) ->
  state = history.state

  if 'title' of newState
    app.title = newState.title
    newState.title = app.title

  for key, val of newState
    if val is null
      delete state[key]
    else
      state[key] = val

  history.replaceState(state, '', document.location.href)

  document.dispatchEvent(new CustomEvent('state:updated'))


# vim: set ft=coffee:
