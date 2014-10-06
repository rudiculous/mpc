(function(io, $) {
    "use strict";

    window.APP = {};

    var socket = io();

    // The global state.
    var state = {};

    window.APP.mpd = function(command, args) {
        socket.emit('mpd:command', {
            'command': command,
            'args': args || []
        });
    };

    // Returns a deep copy of the global state.
    window.APP.mpd.getState = function() {
        return JSON.parse(JSON.stringify(state));
    };

    socket.once('socket:ready', function(initialState) {
        state = initialState;
        $(window).trigger('mpd:stateUpdate');
    });

    socket.on('mpd:updated', function(newState) {
        state = newState;
        $(window).trigger('mpd:stateUpdate');
    });
}(io, jQuery));
