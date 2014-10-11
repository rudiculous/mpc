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
  get: -> document.head.title
  set: (newTitle) ->
    document.title =
      if newTitle
        newTitle + ' | ' + baseTitle
      else
        baseTitle


# Sends data to the server and waits for a response.
app.mpd = (command, args, callback) ->
  last = arguments.length - 1

  if arguments.length < 2
    throw new Error('mpd() called with too few arguments.')

  if typeof(arguments[last]) isnt 'function'
    throw new Error('Last argument to mpd() should be a callback.')

  command = arguments[0]
  args = Array.prototype.slice.call(arguments, 1, last)
  callback = arguments[last]

  socket.emit 'mpd:command',
    command: command
    args: args
  , callback

  return

app.views = {}

app.blocks =
  navigation: document.getElementById 'navigation'
  controls: document.getElementById 'controls'
  main: document.getElementById 'main'

# Dispatch events when something has changed.
socket.on 'mpd:changed', (what) ->
  document.dispatchEvent(new CustomEvent('mpd:changed',
    detail:
      what: what
  ))

  document.dispatchEvent(new CustomEvent('mpd:changed:' + what))

  return


# When navigation takes place, run the router.
router = window.APP_LIB.router
document.addEventListener 'navigation:page', router(app.blocks.main), false


# Catch navigation events.
#
# Loosely based on [turbolinks](https://github.com/rails/turbolinks)
attachClickHandler = (event) ->
  unless event.defaultPrevented
    document.removeEventListener 'click', clickHandler, false
    document.addEventListener 'click', clickHandler, false

  return

clickHandler = (event) ->
  return if event.defaultPrevented or # event was cancelled
    event.which > 1 or # different button than the left mouse
    event.metaKey or # modifier key was clicked
    event.ctrlKey or
    event.shiftKey or
    event.altKey

  link = event.target
  link = link.parentNode until !link.parentNode or link.nodeName is 'A'

  # Clicked element was not a link.
  return unless link.nodeName is 'A'

  # The link points to a different origin. Ignore it.
  unless link.origin is document.location.origin
    return

  # @todo Check the target of the link.

  event.preventDefault()

  state = history.state
  state.location =
    hash: link.hash
    host: link.host
    hostname: link.hostname
    href: link.href
    origin: link.origin
    pathname: link.pathname
    port: link.port
    protocol: link.protocol
    search: link.search

  history.pushState(state, '', link.href)
  document.dispatchEvent(new CustomEvent('navigation:page'))
  document.dispatchEvent(new CustomEvent('state:updated'))

  return

document.addEventListener 'click', attachClickHandler, true

# Delay execution of function long enough to miss the popstate event
# that is fired by some browsers on the initial page load.
#
# @todo Is this (still) necessary?
setTimeout ->
  window.addEventListener 'popstate', (event) ->
    document.dispatchEvent(new CustomEvent('navigation:page'))
    document.dispatchEvent(new CustomEvent('state:updated'))
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

  document.dispatchEvent(new CustomEvent('navigation:page'))
  document.dispatchEvent(new CustomEvent('state:updated'))
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
