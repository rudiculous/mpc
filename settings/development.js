"use strict";

// Use a default secret for development.
var SECRET = process.env.SECRET || 'keyboard cat';

module.exports = {
    'secret': SECRET,
    'server': {
        'host': process.env.HOST || '127.0.0.1',
        'port': process.env.PORT || 3000,
    },
    'mpd': {
        'host': process.env.MPD_HOST || 'localhost',
        'port': process.env.MPD_PORT || 6600,
    },
    'middleware': {
        'serve-static': true,
        'errorhandler': true,
    },
    'locals': {
        'staticBase': '/static',
    },
};
