"use strict";

/** # Initialization */

var MPD_HOST = process.env.MPD_HOST || 'localhost';
var MPD_PORT = process.env.MPD_PORT || 6600;

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

exports.removeListener = function removeListener() {
    events.removeListener.apply(events, arguments);
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

/** Returns a deep copy of the current state. */
exports.getState = function getState() {
    return JSON.parse(JSON.stringify(state));
};


/**
 * ## Commands
 *
 * The commands that follow are commands that are publicly available.
 * That is, these commands are safe to be called by a client.
 */

exports.commands = {};


/** ### Querying MPD's status */

/** Reports the current status of the player and the volume level. */
exports.commands.status = function status() {
    write('status');
};

/** Displayes statistics. */
exports.commands.stats = function stats() {
    write('stats');
};


/** ### Playback options */

/** Toggles `consume`. */
exports.commands.consume = toggleFactory('consume');

/**
 * Sets crossfade.
 *
 * @param {Number} seconds
 */
exports.commands.crossfade = function crossfade(seconds) {
    write('crossfade', seconds);
};

/** @todo mixrampdb */
/** @todo mixrampdelay */

/** Toggles `random`.*/
exports.commands.random = toggleFactory('random');

/** Toggles `repeat`. */
exports.commands.repeat = toggleFactory('repeat');

/**
 * Sets the volume.
 *
 * @param {Number} vol A level between 0-100.
 */
exports.commands.volume = function volume(vol) {
    write('setvol', vol);
};

/** Toggles `single`. */
exports.commands.single = toggleFactory('single');

/**
 * Sets the replay gain mode. One of `off`, `track`, `album`, `auto`.
 *
 * @param {String} mode
 */
exports.commands.replayGainMode = function replayGainMode(mode) {
    write('replay_gain_mode', mode);
};

/** @todo replay_gain_status */

/** ### Controlling playback */

/** Plays the next song in the playlist. */
exports.commands.next = function next() {
    write('next');
};

/** Toggles playback. */
exports.commands.pause = toggleFactory('state', true, 'pause', 'pause');

/** Alias for pause. */
exports.commands.toggle = exports.commands.pause;

/**
 * Begins paying the playlist at song number `songpos`.
 *
 * @param {Number} [songpos]
 */
exports.commands.play = function play(songpos) {
    if (arguments.length === 0) {
        write('play');
    }
    else {
        write('play', songpos);
    }
};

/** @todo playid [SONGID] */

/** Plays the previous song in the playlist. */
exports.commands.previous = function previous() {
    write('previous');
};

/**
 * Seeks to the position `time` of entry `songpos`.
 *
 * @param {Number} songpos
 * @param {Number} time    In seconds, fractions allowed.
 */
exports.commands.seek = function seek(songpos, time) {
    write('seek', songpos, time);
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
exports.commands.seekcur = function seekcur(time) {
    write('seekcur', time);
};

/** Stops playing. */
exports.commands.stop = function stop() {
    write('stop');
};




/** # Private methods */

/**
 * Initializes the internal state.
 */
function updateState() {
    if (client != null) {
        client.write([
            'noidle',
            'command_list_begin',
            'currentsong',
            'status',
            'stats',
            'command_list_end',
            'idle',
        ].join('\n') + '\n');
    }
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
 * Writes sanitized data to the MPD connection.
 *
 * First the command `noidle` is sent.
 *
 * Newlines are replaced by spaces and all arguments to this function
 * are joined into a single string (space separated).
 *
 * Finally the command `idle` is sent.
 *
 * @param {String} ...data
 */
function write(data) {
    var i;

    if (arguments.length < 1) {
        // nothing to do here...
        return;
    }

    if (client !== null) {
        data = 'noidle\n';
        for (i = 0; i < arguments.length; i++) {
            if (i > 0) {
                data += ' ';
            }
            data += arguments[i].replace('\n', ' ');
        }
        data += '\n'
        data += 'idle\n'

        client.write(data);
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
        write(command, value ? '1' : '0');
    };
}
