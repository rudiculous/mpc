(function(io, $) {
    "use strict";

    var socket = io();

    window.APP = {};

    window.APP.mpd = function(command, args, callback) {
        var last = arguments.length - 1;

        if (arguments.length < 2) {
            throw new Error('mpd() called with too few arguments.');
        }

        if (typeof(arguments[last]) !== 'function') {
            throw new Error('Last argument to mpd() should be a callback.');
        }

        command = arguments[0];
        args = Array.prototype.slice.call(arguments, 1, last);
        callback = arguments[last];

        socket.emit('mpd:command', {
            'command': command,
            'args': args
        }, callback);
    };

    socket.on('mpd:changed', function(message) {
        $(window).trigger('mpd:changed', message);
        $(window).trigger('mpd:changed:' + message);
    });

    socket.once('socket:ready', function() {
    });
}(io, jQuery));
