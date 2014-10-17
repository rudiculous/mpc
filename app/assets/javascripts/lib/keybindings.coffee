"use strict"


window.APP_LIB ||= {}


attachKeyHandler = (event) ->
  unless event.defaultPrevented
    document.removeEventListener 'keydown', keyHandler, false
    document.addEventListener 'keydown', keyHandler, false


keyHandler = (event) ->
  return if event.defaultPrevented

  input = event.target

  if input.nodeName is 'INPUT' or input.nodeName is 'TEXTAREA'
    return

  fullKeyName = event.key.toLowerCase()
  fullKeyName = "shift+#{fullKeyName}" if event.shiftKey
  fullKeyName = "meta+#{fullKeyName}" if event.metaKey
  fullKeyName = "ctrl+#{fullKeyName}" if event.ctrlKey
  fullKeyName = "alt+#{fullKeyName}" if event.altKey

  eventDetail =
    detail:
      parent: event
      altKey: event.altKey
      ctrlKey: event.ctrlKey
      metaKey: event.metaKey
      shiftKey: event.shiftKey
      key: event.key
      fullKeyName: fullKeyName

  document.dispatchEvent new CustomEvent('keylistener:key', eventDetail)
  document.dispatchEvent new CustomEvent("keylistener:key:#{fullKeyName}", eventDetail)


registerKeyBinding = (key, callback, cancelDefault = true) ->
  document.addEventListener "keylistener:key:#{key}", (event) ->
    event.detail.parent.preventDefault() if cancelDefault
    callback.apply this, arguments
  , false


window.APP_LIB.keybindings =
  attachKeyHandler: attachKeyHandler
  keyHandler: keyHandler
  registerKeyBinding: registerKeyBinding
