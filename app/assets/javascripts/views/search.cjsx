# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.search = {}

{parseMPDResponse} = window.APP_LIB
{mpd} = window.MPD_APP
{Directory, File} = window.MPD_APP.views.generics.items

components.mount = (where) ->
  React.renderComponent(<div />, where)


# vim: set ft=coffee:
