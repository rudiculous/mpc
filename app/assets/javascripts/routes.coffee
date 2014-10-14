"use strict"

{views} = window.MPD_APP
{route} = window.APP_LIB


route(['/', '/now_playing'])    -> views.nowPlaying
route('/file_browser')          -> views.fileBrowser
route('/search')                -> views.search


# vim: set ft=coffee:
