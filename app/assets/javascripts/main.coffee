"use strict"

socket = io()
app = {}

window.MPD_APP = app

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

# Dispatch events when something has changed.
socket.on 'mpd:changed', (what) ->
  document.dispatchEvent(new CustomEvent('mpd:changed',
    what: what
  ))

  document.dispatchEvent(new CustomEvent('mpd:changed:' + what))

  return


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

  state =
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
  document.dispatchEvent(new CustomEvent('navigation:page',
    detail: state
  ))

  return

document.addEventListener 'click', attachClickHandler, true

# Delay execution of function long enough to miss the popstate event
# that is fired by some browsers on the initial page load.
#
# @todo Is this (still) necessary?
setTimeout ->
  window.addEventListener 'popstate', (event) ->
    document.dispatchEvent(new CustomEvent('navigation:page',
      detail: event.state
    ))
, 500

setTimeout ->
  document.dispatchEvent(new CustomEvent('navigation:page',
    detail:
      hash: document.location.hash
      host: document.location.host
      hostname: document.location.hostname
      href: document.location.href
      origin: document.location.origin
      pathname: document.location.pathname
      port: document.location.port
      protocol: document.location.protocol
      search: document.location.search
  ))
, 0
