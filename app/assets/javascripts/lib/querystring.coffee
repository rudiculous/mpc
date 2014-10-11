"use strict"


window.APP_LIB ||= {}


# Parses the query string.
#
# @param {String} search
# @returns {Object}
window.APP_LIB.parseQueryString = (search) ->
  params = {}

  if search isnt ''
    search = search.substring(1) if search[0] is '?'
    parts = search.split(/[&;]/)

    for part in parts
      i = part.indexOf '='

      key = decodeURIComponent(
        if i > -1
          part.substring(0, i)
        else
          part
      )

      value =
        if i > -1
          decodeURIComponent part.substring(i + 1)
        else
          true
      
      params[key] ||= []
      params[key].push value

  return params


# Builds a query string.
#
# @param {Object} params
# @param {String} [separator=&]
# @returns {String}
window.APP_LIB.stringifyQuery = (params, separator = '&') ->
  search = ''

  for key, value of params
    key = encodeURIComponent key

    continue if key is ''

    if value is true
      search += separator + key
    else
      value = encodeURIComponent value
      search += separator + key + '=' + value

    if search isnt ''
      search = search.substring(separator.length)

  return search


# vim: set ft=coffee:
