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
# @param {String} data The response from MPD.
# @param {null|Array|Object} [split=null]
# @param {String} [sep=': '] Separates key-values.
# @returns {Object|Array} Returns either the parsed data or an array of
# parsed segments.
window.APP_LIB.parseMPDResponse = (data, split = null, sep = ': ') ->
  entries = []
  lines = data.split '\n'
  entry = null
  transform = unit

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
        entries.push( transform(entry) ) if entry isnt null
        transform = split[key]
        entry = {}

      entry[key] = value

  if split is null
    return entry
  else
    entries.push( transform(entry) ) if entry isnt null
    return entries


unit = (x) -> x


# vim: set ft=coffee:
