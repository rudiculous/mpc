"use strict"

window.APP_LIB ||= {}

formatTime = (seconds) ->
  formatted = ''

  seconds = Number(seconds)

  if seconds > 3600
    nr = Math.floor( (seconds - (seconds % 3600)) / 3600 )
    formatted += String(nr) + ':'
    seconds = seconds % 3600

  nr = Math.floor( (seconds - (seconds % 60)) / 60 )
  if formatted isnt '' and nr < 10
    nr = '0' + nr
  formatted += String(nr) + ':'
  seconds = seconds % 60

  seconds = Math.floor(seconds)

  if seconds < 10
    seconds = '0' + seconds

  formatted += String(seconds)

  return formatted

window.APP_LIB.formatTime = formatTime
