"use strict";

module.exports = {
    'secret': process.env.SECRET,
    'server': {
        'host': process.env.HOST || '127.0.0.1',
        'port': process.env.PORT,
    },
    'mpd': {
        'host': process.env.MPD_HOST || 'localhost',
        'port': process.env.MPD_PORT || 6600,
    },
    'middleware': {
    },
    'locals': {
        'staticBase': '/static',
    },
};
