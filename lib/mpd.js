"use strict";

/** # Initialization */

var MPD_HOST = process.env.MPD_HOST || 'localhost';
var MPD_PORT = process.env.MPD_PORT || 6600;

var ENDL = '\r\n';

var net = require('net');
var EventEmitter = require('events').EventEmitter;

var client = null;
var state = {};
var events = new EventEmitter();


/** # Public API */

/** ## Event handlers */

exports.on = function on() {
    events.on.apply(events, arguments);
};

exports.once = function once() {
    events.once.apply(events, arguments);
};


/** ## Connection */

/**
 * Connects to MPD.
 *
 * @param {Number} [port]
 * @param {String} [host]
 */
exports.connect = function connect(port, host) {
    if (arguments.length < 1) port = MPD_PORT;
    if (arguments.length < 2) host = MPD_HOST;

    if (client === null) {
        state = {}; // reset state
        client = net.connect({
            'port': port,
            'host': host,
        }, function onConnect() {
            updateState();
        });

        events.once('updated', function onceUpdated() {
            events.emit('connection:ready');
        });

        client.on('data', dataHandler);
        events.on('changed', changedHandler);

        client.on('end', function onEnd() {
            client = null;
            events.emit('connection:closed');
        });
    }
    else {
        events.emit('connection:error', new Error('Connection already open.'));
    }
};

/** Closes the connection to MPD. */
exports.end = function end() {
    if (client !== null) {
        client.end();
    }
};

/** Alias for end. */
exports.close = exports.end;


/** ## Querying MPD's status */

/** Reports the current status of the player and the volume level. */
exports.status = function status() {
    write('status');
};

/** Displayes statistics. */
exports.stats = function stats() {
    write('stats');
};


/** ## Playback options */

/** Toggles `consume`. */
exports.consume = toggleFactory('consume');

/**
 * Sets crossfade.
 *
 * @param {Number} seconds
 */
exports.crossfade = function crossfade(seconds) {
    write([
        'crossfade',
        seconds,
    ].join(' '));
};

/** @todo mixrampdb */
/** @todo mixrampdelay */

/** Toggles `random`.*/
exports.random = toggleFactory('random');

/** Toggles `repeat`. */
exports.repeat = toggleFactory('repeat');

/**
 * Sets the volume.
 *
 * @param {Number} vol A level between 0-100.
 */
exports.volume = function volume(vol) {
    write([
        'setvol',
        vol,
    ].join(' '));
};

/** Toggles `single`. */
exports.single = toggleFactory('single');

/**
 * Sets the replay gain mode. One of `off`, `track`, `album`, `auto`.
 *
 * @param {String} mode
 */
exports.replayGainMode = function replayGainMode(mode) {
    write([
        'replay_gain_mode',
        mode,
    ].join(' '));
};

/** @todo replay_gain_status */

/** ## Controlling playback */

/** Plays the next song in the playlist. */
exports.next = function next() {
    write('next');
};

/** Toggles playback. */
exports.pause = toggleFactory('pause', true);

/** Alias for pause. */
exports.toggle = exports.pause;

/**
 * Begins paying the playlist at song number `songpos`.
 *
 * @param {Number} [songpos]
 */
exports.play = function play(songpos) {
    var command = ['play'];
    if (arguments.length > 0) {
        command.push(songpos);
    }
    write(command.join(' '));
};

/** @todo playid [SONGID] */

/** Plays the previous song in the playlist. */
exports.previous = function previous() {
    write('previous');
};

/**
 * Seeks to the position `time` of entry `songpos`.
 *
 * @param {Number} songpos
 * @param {Number} time    In seconds, fractions allowed.
 */
exports.seek = function seek(songpos, time) {
    write([
        'seek',
        songpos,
        time,
    ].join(' '));
};

/** @todo seekid {SONGID} {TIME} */

/**
 * Seeks to position `time` within the current song.
 *
 * If `time` is prefixed by `+` or `-`, then the time is relative to the
 * current playing position.
 *
 * @param {Number|String} time In seconds, fractions allowed.
 */
exports.seekcur = function seekcur(time) {
    write([
        'seekcur',
        time
    ].join(' '));
};

/** Stops playing. */
exports.stop = function stop() {
    write('stop');
};




/** # Private methods */

/**
 * Initializes the internal state.
 */
function updateState() {
    write([
        'command_list_begin',
        'currentsong',
        'status',
        'stats',
        'command_list_end',
    ]);
}

/**
 * Handles the incoming data from the client.
 *
 * @param {Buffer} data
 */
function dataHandler(data) {
    var updated = false,
        i, key, value;

    //console.info('received', {data:data.toString()});

    // @todo Do we need toString?
    data.toString().split('\n').forEach(function(line) {
        if (line === 'OK' || line === '' || line === 'list_OK') {
            // For now we ignore these lines.
        }
        else if (line.match(/^changed: /)) {
            value = line.substring('changed: '.length);
            events.emit('changed', value);
        }
        else if (line.match(/: /)) {
            i = line.indexOf(': ');
            key = line.substring(0, i);
            value = line.substring(i + 2);

            state[key] = value;
            updated = true;
        }
        else if (line.match(/^OK MPD/)) {
            // mpd version
        }
        else {
            console.error('unknown line,', {line:line});
        }
    });

    if (updated) {
        events.emit('updated', state);
    }
}

/**
 * Handles `changed` events.
 *
 * @param {String} what
 *
 * @todo
 */
function changedHandler(what) {
    updateState();
}

/**
 * Writes data to the client.
 *
 * @param {Array|String} data
 */
function write(data) {
    if (client !== null) {
        client.write('noidle' + ENDL);

        if (!Array.isArray(data)) {
            data = [data];
        }

        data = data.reduce(function(total, line) {
            if (total) total += ENDL;
            return total + line.split('\n').join(ENDL);
        }) + ENDL;

        //console.log('writing', {data:data});
        client.write(data);
        client.write('idle' + ENDL);
    }
}

/**
 * Creates a toggle method.
 *
 * @param {String}   key           The name of the key within the state.
 * @param {Boolean} [invert=false] Invert the logic for computing the current state.
 * @param {String}  [command]      The command to send to MPD. Defaults to `key`.
 * @param {Mixed}   [trueVal=1]    The value to consider as `true`.
 * @returns {Function}
 */
function toggleFactory(key, invert, command, trueVal) {
    if (arguments.length < 3) {
        command = key;
    }
    if (arguments.length < 4) {
        trueVal = '1';
    }

    return function toggle(value) {
        if (arguments.length === 0) {
            value = state[key] === trueVal;
            if (invert) {
                value = !value;
            }
        }
        write([
            command,
            value ? '1' : '0',
        ].join(' '));
    };
}
