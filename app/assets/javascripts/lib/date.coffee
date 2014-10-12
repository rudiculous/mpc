"use strict"


window.APP_LIB ||= {}


# ### Formats time.
#
# @param {Number} seconds
# @returns {String}
formatTime = (seconds) ->
  formatted = ''

  seconds = Math.round seconds

  if seconds >= 3600
    nr = seconds // 3600
    formatted += String(nr) + ':'
    seconds = seconds % 3600

  nr = seconds // 60
  if formatted isnt '' and nr < 10
    nr = '0' + nr
  formatted += String(nr) + ':'
  seconds = seconds % 60

  if seconds < 10
    seconds = '0' + seconds

  formatted += String(seconds)

  return formatted

window.APP_LIB.formatTime = formatTime
