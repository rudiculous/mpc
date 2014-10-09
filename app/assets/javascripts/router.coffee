"use strict"

views = window.MPD_APP.views

document.addEventListener 'navigation:page', (event) ->
  if event.detail
    {href, pathname} = event.detail

  href = document.location.href unless href
  pathname = document.location.pathname unless pathname

  views.playbackControls.mount(document.getElementById('controls'))
  views.browser.mount(document.getElementById('main'))
, false
