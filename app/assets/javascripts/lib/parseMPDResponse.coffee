"use strict"


window.APP_LIB ||= {}


# ### Parses responses from MPD.
#
# The parameter `split` should be an object describing if and how to
# split the response from MPD into an array. This value should be:
# * `null`. In this case the response won't be split.
# * An `Array` of keywords. In this case the response will be split at
#   these keywords.
# * An `Object` mapping keywords to `Function`s. The response will be
#   split at these keywords, and each segment will be passed through the
#   respective `Function`.
#
# @param {String}            data           The response from MPD.
# @param {null|Array|Object} [split=null]
# @param {String}            [sep=': ']     Separates key-values.
# @param {Number}            [pageNo]       Page number.
# @param {Number}            [rpp]          Records per page.
# @returns {Object|Array} Returns either the parsed data or an array of
# parsed segments.
window.APP_LIB.parseMPDResponse = (data, split = null, sep = ': ', pageNo = null, rpp = null) ->
  entries = []
  lines = data.split '\n'
  entry = null
  transform = unit
  entryIndex = 0

  if rpp?
    pageNo ?= 0
    start = pageNo * rpp
    end = (pageNo + 1) * rpp

  if split is null
    entry = {}
  else if Array.isArray split
    ns = {}
    for item in split
      ns[item] = unit
    split = ns

  for line in lines
    index = line.indexOf sep

    if index > -1
      key = line.substring 0, index
      value = line.substring index + sep.length

      if split isnt null and split[key]
        if entry isnt null
          if !rpp? or start <= entryIndex < end
            entries.push transform(entry)

          entryIndex++

        transform = split[key]
        entry = {}

      entry[key] = value

  if split is null
    return entry
  else
    if entry isnt null
      if !rpp? or start <= entryIndex < end
        entries.push transform(entry)

      entryIndex++

    if rpp?
      return [entries, entryIndex]
    else
      return entries


unit = (x) -> x


# vim: set ft=coffee:
