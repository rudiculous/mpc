"use strict"

views = window.MPD_APP.views

getDetails = (detail) ->
  result = {}
  for key in [ 'hash' , 'host' , 'hostname' , 'href' , 'origin' ,
               'pathname' , 'port' , 'protocol' , 'search' ]
    result[key] =
      if detail && detail[key]
        detail[key]
      else
        document.location[key]
  return result

document.addEventListener 'navigation:page', (event) ->
  {href, pathname} = getDetails(event.detail)

  console.log pathname

  views.playbackControls.mount document.getElementById('controls')
  views.browser.mount document.getElementById('main')
, false
