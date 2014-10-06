(function(io) {
    "use strict";

    window.APP = {};

    var socket = io();

    //window.APP.socket = socket;
    window.APP.mpd = function(command, args) {
        socket.emit('mpd:command', {
            'command': command,
            'args': args || []
        });
    };

    window.APP.mpd.state = {};

    socket.once('socket:ready', function(initialState) {
        window.APP.mpd.state = initialState;
    });

    socket.on('mpd:updated', function(state) {
        window.APP.mpd.state = state;
    });

    window.APP.mpd.onceSocketReady = function(callback) {
        socket.once('socket:ready', function() {
            callback.apply({}, arguments);
        });
    };

    window.APP.mpd.onUpdate = function(callback) {
        socket.on('mpd:updated', function() {
            callback.apply({}, arguments);
        });
    };
}(io));
