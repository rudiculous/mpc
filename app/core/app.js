"use strict";

/** # Dependencies */
var fs = require('fs');
var http = require('http');
var pathM = require('path');

var bodyParser = require('body-parser');
var express = require('express');
var io = require('socket.io');
var swig = require('swig');
var rdclMiddleware = require('rdcl-middleware');


/** # Initialization */
var root = pathM.join(__dirname, '../../');
var app = exports = module.exports = express();

var settings = require('../../settings');
app.config = settings.config;

app.logger = new rdclMiddleware.Logger();
app.use(bodyParser.json());
app.enable('trust proxy');

app.server = http.Server(app);
app.listen = app.server.listen.bind(app.server);

app.io = io(app.server);
app.mpd = require('../../lib/mpd');
app.mpd.connect(app.config.mpd.port, app.config.mpd.host);


/**
 * If the connection to MPD gets lost, we try to reestablish the
 * connection. To prevent spamming, we wait a little longer between each
 * attempt (up to a certain maximum).
 */
var retryAfterMS_initial = 250;
var retryAfterMS_incr = 250;
var retryAfterMS_max = 5000;
var retryAfterMS = retryAfterMS_initial;

function reconnectMPD(err) {
    if (err) {
        app.logger.error('MPD connection lost: %s', err.message);
    }
    else {
        app.logger.warning('MPD connection lost.');
    }

    setTimeout(function reconnect() {
        if (retryAfterMS < retryAfterMS_max) {
            retryAfterMS += retryAfterMS_incr;
        }

        app.logger.info('Trying to reestablish MPD connection.');
        app.mpd.connect(app.config.mpd.port, app.config.mpd.host);
    }, retryAfterMS);
}

app.mpd.on('connection:closed', reconnectMPD);
app.mpd.on('connection:error', reconnectMPD);
app.mpd.on('connection:ready', function() {
    retryAfterMS = retryAfterMS_initial;
    app.logger.info('Successfully connected to MPD.');
});


/** ## Template engine */
var templateRoot = pathM.join(root, 'app/templates');
swig.setDefaults({ 'loader': new rdclMiddleware.TemplateLoader(templateRoot) });
app.engine('swig.html', swig.renderFile);
app.set('view engine', 'swig.html');
app.set('views', templateRoot);

/** ## Assets */
if (settings.environment === 'production') {
    var assets = rdclMiddleware.assets({
        'environment': 'production',
        'root': root,
        'assetsBaseURI': settings.config.locals.staticBase + '/assets',
        'manifest': require('../../static/assets/manifest'),
    });
    app.use(assets);
}
else {
    var assets = rdclMiddleware.assets({
        'environment': 'development',
        'root': root,
        'assetsBaseURI': '/assets',
        'manifest': require('../assets/manifest'),
    });
    app.use(assets);
    app.use('/assets', assets.serveAssets);
}

/** Set locals. Locals are made available to the template parser. */
Object.keys(settings.config.locals).forEach(function (key) {
    app.locals[key] = settings.config.locals[key];
});
