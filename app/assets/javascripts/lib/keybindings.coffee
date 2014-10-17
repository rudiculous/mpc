"use strict"


window.APP_LIB ||= {}


window.APP_LIB.keyListener = keyListener = (event) ->
  input = event.target

  if input.nodeName is 'INPUT' or input.nodeName is 'TEXTAREA'
    return

  document.dispatchEvent new CustomEvent('keylistener:key',
    detail:
      altKey: event.altKey
      ctrlKey: event.ctrlKey
      metaKey: event.metaKey
      shiftKey: event.shiftKey
      key: event.key
  )
