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
// @todo If the connection gets lost, reestablish the connection.


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
