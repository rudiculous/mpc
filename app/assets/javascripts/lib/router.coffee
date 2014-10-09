"use strict"

window.APP_LIB ||= {}


routes = []


class Route
  constructor: (path, @action) ->
    @path = new RegExp "^#{path}$"

  matches: (path) ->
    path.match(@path)

  execute: (where, params) ->
    @action.mount where, params


router = (where) ->
  (event) ->
    {pathname, search} = document.location

    params = window.APP_LIB.parseQueryString search

    React.unmountComponentAtNode main

    for route in routes
      match = route.matches pathname
      if match
        route.execute where,
          params: params
          match: match
        return

    console.warn 'no route matched'
    try
      window.MPD_APP.views.routeNotFound.mount where,
        params:params
    catch err
      console.error 'Error while showing routeNotFound view.', err

    return


# Creates a route.
window.APP_LIB.route = (paths, action) ->
  if !Array.isArray(paths)
    paths = [paths]

  for path in paths
    routes.push(new Route(path, action))

  return


# When navigation takes place, run the router.
document.addEventListener 'navigation:page', router, false

# vim: set ft=coffee:
