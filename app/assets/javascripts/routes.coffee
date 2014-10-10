"use strict"

{views} = window.MPD_APP
{route} = window.APP_LIB


route(['/', '/now_playing'])    -> views.nowPlaying
route('/browser')               -> views.browser


# vim: set ft=coffee:
