"use strict"

# Finishes bootstrapping the application.
#
# All actions that need to be executed after everything has been
# initialized go here.

{views, blocks} = window.MPD_APP

views.playbackControls.mount blocks.controls
views.navigation.mount blocks.navigation

# vim: set ft=coffee:
