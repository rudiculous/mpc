"use strict";

var app = require('./core/app');

app.io.on('connection', function connection(socket) {
    function updateListener(state) {
        socket.emit('mpd:updated', state);
    }

    // add listeners
    app.mpd.on('updated', updateListener);

    socket.on('mpd:command', function command(data) {
        var command, args;
        if (data && data.command && app.mpd.commands[data.command]) {
            command = app.mpd.commands[data.command];
            args = data.args;

            if (!Array.isArray(args)) {
                args = [];
            }

            command.apply({}, args);
        }
    });

    socket.on('disconnect', function disconnect() {
        // cleanup
        app.mpd.removeListener('updated', updateListener);
    });
});
