"use strict";

var app = require('./core/app');

app.io.on('connection', function connection(socket) {
    function changedHandler(message) {
        socket.emit('mpd:changed', message);
    }

    // add listeners
    app.mpd.on('changed', changedHandler);

    socket.on('mpd:command', function executeCommand(data, callback) {
        var command, args;
        if (data && data.command) {
            command = data.command;
            args = data.args;

            if (!Array.isArray(args)) {
                args = [];
            }

            args.unshift(command);
            args.push(function(err, res) {
                if (callback && typeof(callback) === 'function') {
                    if (err) {
                        if (err.message) {
                            err = 'error: ' + err.message;
                        }
                        else {
                            err = 'unknown error';
                        }
                    }
                    callback(err, res);
                }
            });

            app.mpd.push.apply(null, args);
        }
    });

    socket.on('disconnect', function disconnect() {
        // cleanup
        app.mpd.removeListener('updated', changedHandler);
    });

    socket.emit('socket:ready');
});
