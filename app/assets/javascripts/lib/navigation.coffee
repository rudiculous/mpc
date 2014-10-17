"use strict"


window.APP_LIB ||= {}


# Catch navigation events.
#
# Loosely based on [turbolinks](https://github.com/rails/turbolinks)
attachFormSubmitHandler = (event) ->
  unless event.defaultPrevented
    document.removeEventListener 'submit', formSubmitHandler, false
    document.addEventListener 'submit', formSubmitHandler, false

attachClickHandler = (event) ->
  unless event.defaultPrevented
    document.removeEventListener 'click', clickHandler, false
    document.addEventListener 'click', clickHandler, false

formSubmitHandler = (event) ->
  form = event.target
  form = form.parentNode until !form.parentNode or form.nodeName is 'FORM'

  # Submitted element was not a form (this should be unlikely...).
  return unless form.nodeName is 'FORM'

  # For now, only handle GET forms.
  return unless form.method.toLowerCase() is 'get'

  # The form submits to a different origin. Ignore it.
  [protocol, host, rest...] = form.action.split /\/+/
  origin = protocol + '//' + host
  return unless origin is document.location.origin

  event.preventDefault()

  serialized = ''
  for element in form.elements
    if element.name
      serialized += "&#{encodeURIComponent element.name}"
      if element.value
        serialized += "=#{encodeURIComponent element.value}"

  serialized = serialized.substring(1) if serialized
  state = history.state

  href = form.action
  pathname = rest.join '/'
  [hostname, port] = host.split ':'
  [pathname, hash] = pathname.split '#'
  [pathname, search] = pathname.split '?'

  hash ?= ''
  search ?= ''

  if serialized
    search += '&' + serialized
    href +=
      if href.match /[?&]$/
        serialized
      else if href.match /\?/
        "&#{serialized}"
      else
        "?#{serialized}"

  state.location =
    hash: hash
    host: host
    hostname: hostname
    href: href
    origin: origin
    pathname: pathname
    port: port
    protocol: protocol
    search: search

  history.pushState(state, '', href)
  document.dispatchEvent new CustomEvent('navigation:page')
  document.dispatchEvent new CustomEvent('state:updated')

clickHandler = (event) ->
  return if event.defaultPrevented or # event was cancelled
    event.which > 1 or # different button than the left mouse
    event.metaKey or # modifier key was clicked
    event.ctrlKey or
    event.shiftKey or
    event.altKey

  link = event.target
  link = link.parentNode until !link.parentNode or link.nodeName is 'A'

  # Clicked element was not a link.
  return unless link.nodeName is 'A'

  # The link points to a different origin. Ignore it.
  unless link.origin is document.location.origin
    return

  # @todo Check the target of the link.

  event.preventDefault()

  state = history.state
  state.location =
    hash: link.hash
    host: link.host
    hostname: link.hostname
    href: link.href
    origin: link.origin
    pathname: link.pathname
    port: link.port
    protocol: link.protocol
    search: link.search

  history.pushState(state, '', link.href)
  document.dispatchEvent new CustomEvent('navigation:page')
  document.dispatchEvent new CustomEvent('state:updated')


window.APP_LIB.navigation =
  attachFormSubmitHandler: attachFormSubmitHandler
  attachClickHandler: attachClickHandler
  formSubmitHandler: formSubmitHandler
  clickHandler: clickHandler
