"use strict";

var app = require('./core/app');

app.io.on('connection', function(socket) {
    app.logger.info('a user connected');
});
