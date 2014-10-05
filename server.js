#!/usr/bin/env node
"use strict";

var app = require('./app');
var config = app.config;

var server = app.listen(config.server.port, config.server.host,
    function serverStarted() {
        app.logger.info('Started server on %s:%d.',
            server.address().address,
            server.address().port);
    });
