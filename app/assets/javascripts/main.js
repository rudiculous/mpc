(function(io) {
    "use strict";

    window.APP = {};

    var socket = io();

    window.APP.socket = socket;
    window.APP.mpd = function(command, args) {
        socket.emit('mpd:command', {
            'command': command,
            'args': args || []
        });
    };
}(io));
