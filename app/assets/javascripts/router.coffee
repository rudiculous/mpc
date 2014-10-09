"use strict"

views = window.MPD_APP.views

document.addEventListener 'navigation:page', ->
  {pathname} = history.state.location

  console.log pathname

  views.playbackControls.mount document.getElementById('controls')
  views.browser.mount document.getElementById('main')
, false
