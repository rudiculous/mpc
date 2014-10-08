"use strict"

socket = io()
app = {}

window.MPD_APP = app

app.mpd = (command, args, callback) ->
    last = arguments.length - 1

    if arguments.length < 2
        throw new Error('mpd() called with too few arguments.')

    if typeof(arguments[last]) isnt 'function'
        throw new Error('Last argument to mpd() should be a callback.')

    command = arguments[0]
    args = Array.prototype.slice.call(arguments, 1, last)
    callback = arguments[last]

    socket.emit 'mpd:command',
        command: command
        args: args
    , callback

    return

app.views = {}

socket.on 'mpd:changed', (what) ->
    document.dispatchEvent(new CustomEvent('mpd:changed',
        what: what
    ))

    document.dispatchEvent(new CustomEvent('mpd:changed:' + what))

    return
