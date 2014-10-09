"use strict";

/** # Initialization */

var MPD_HOST = process.env.MPD_HOST || 'localhost';
var MPD_PORT = process.env.MPD_PORT || 6600;

var net = require('net');
var EventEmitter = require('events').EventEmitter;

var client = null;
var queue = [];
var dataQueue = [];
var mpdStatus = null;
var ev = new EventEmitter();

ev.setMaxListeners(0); // Allows for unlimited listeners.

var commandList = [
    // [Querying MPD's status.](http://www.musicpd.org/doc/protocol/command_reference.html)
    'currentsong', 'status', 'stats',

    // [Playback options.](http://www.musicpd.org/doc/protocol/playback_option_commands.html)
    'consume', 'crossfade', 'mixrampdb', 'mixrampdelay', 'random',
    'repeat', 'setvol', 'single', 'replay_gain_mode',
    'replay_gain_status', 'volume',

    // [Controlling playback.](http://www.musicpd.org/doc/protocol/playback_commands.html)
    'next', 'pause', 'play', 'playid', 'previous', 'seek', 'seekid',
    'seekcur', 'stop',

    // [The current playlist.](http://www.musicpd.org/doc/protocol/queue.html)
    'add', 'addid', 'clear', 'delete', 'deleteid', 'move', 'moveid',
    'playlist', 'playlistfind', 'playlistid', 'playlistinfo',
    'playlistsearch', 'plchanges', 'plchangesposid', 'prio', 'prioid',
    'rangeid', 'shuffle', 'swap', 'swapid', 'addtagid', 'cleartagid',

    // [Stored playlists.](http://www.musicpd.org/doc/protocol/playlist_files.html)
    'listplaylist', 'listplaylistinfo', 'listplaylists', 'load',
    'playlistadd', 'playlistclear', 'playlistdelete', 'playlistmove',
    'rename', 'rm', 'save',

    // [The music database.](http://www.musicpd.org/doc/protocol/database.html)
    'count', 'find', 'findadd', 'list', 'listall', 'listallinfo',
    'listfiles', 'lsinfo', 'readcomments', 'search', 'searchadd',
    'searchaddpl', 'update', 'rescan',
];

var validCommands = {};
commandList.forEach(function (command) {
    validCommands[command] = true;
});


/** # Public API */

/**
 * Returns a deep copy of the command list.
 */
exports.getCommandList = function getCommandList() {
    return JSON.parse(JSON.stringify(commandList));
};

/** ## Event handlers */

exports.on = function on() {
    ev.on.apply(ev, arguments);
};

exports.once = function once() {
    ev.once.apply(ev, arguments);
};

exports.removeListener = function removeListener() {
    ev.removeListener.apply(ev, arguments);
};


/** ## Connection */

/**
 * Cleans up after the connection gets closed.
 */
function cleanup() {
    client = null;
    queue.length = 0;
    dataQueue.length = 0;
    mpdStatus = null;
    ev.removeListener('queue:updated', queueUpdatedHandler);

    // Remove *all* listeners on the _data event.
    ev.removeAllListeners('_data');
}

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
        queue.length = 0; // clear queue
        dataQueue.length = 0; // clear data queue
        mpdStatus = null;

        try {
            client = net.connect({
                'port': port,
                'host': host,
            }, function onConnect() {
                ev.once('_data', function() {
                    // The first data coming back is the `OK MPD version` line.
                    mpdStatus = dataQueue.shift();
                    client.write('idle\n', function() {
                        ev.emit('connection:ready');
                    });
                });
            });
        }
        catch (err) {
            ev.emit('connection:error', err);
            return cleanup();
        }

        client.on('error', function onError(err) {
            ev.emit('connection:error', err);
            return cleanup();
        });

        client.on('data', function onData(data) {
            var matched;

            data = data.toString('utf8');
            //process.stdout.write(data);

            matched = data.match(/^changed: ([^\r\n]*)/);

            if (matched) {
                ev.emit('changed', matched[1]);
                client.write('idle\n');
            }
            else {
                dataQueue.push(data);
                ev.emit('_data');
            }
        });

        ev.once('queue:updated', queueUpdatedHandler);

        client.on('end', function onEnd() {
            cleanup();
            ev.emit('connection:closed');
        });
    }
    else {
        ev.emit('connection:error', new Error('Connection already open.'));
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

/**
 * Pushes a command onto the queue.
 *
 * @param {String...} data
 * @param {Function} callback
 */
exports.push = function push(data, callback) {
    var last = arguments.length - 1;
    var command;
    var args;
    var slice = Array.prototype.slice;

    if (arguments.length === 0
            || typeof(arguments[last]) !== 'function') {

        return; // noop
    }

    callback = arguments[last];

    if (arguments.length < 2) {
        return callback(new Error('Invalid number of arguments.'));
    }

    command = arguments[0];
    args = slice.call(arguments, 1, last).join(' ').replace('\n', '');
    if (args !== '') {
        args = ' ' + args;
    }

    if (!validCommands[command]) {
        return callback(new Error('Invalid command.'));
    }

    queue.push({
        'command': command,
        'args': args,
        'callback': callback,
    });

    setTimeout(function() {
        ev.emit('queue:updated');
    }, 0);
};


/** # Private methods */

/**
 * Wrapper method for shift. This can be used in events handlers, as any
 * arguments are not passed along to shift.
 */
function queueUpdatedHandler() {
    shift();
}

/**
 * Shifts a command from the queue and executes it.
 *
 * If, after finishing the command, there are more commands on the
 * queue, these commands are also executed. When there are no commands
 * left, the `idle` command is sent.
 *
 * @param {Boolean} [skipNoIdle=false]
 */
function shift(skipNoIdle) {
    if (client === null) {
        return;
    }

    var item = queue.shift();
    var command = item.command;
    var args = item.args;
    var callback = item.callback;

    function act() {
        client.write(command + args + '\n', function() {
            getData(function() {
                callback.apply(this, arguments);
                
                if (queue.length) {
                    // If the queue is not empty, don't go idle.
                    shift(true);
                }
                else {
                    // Nothing left to do, wait for more input.
                    client.write('idle\n');
                    ev.once('queue:updated', queueUpdatedHandler);
                }
            });
        });
    }

    if (skipNoIdle) {
        act();
    }
    else {
        client.write('noidle\n', function() {
            getData(act);
        });
    }
}


/**
 * Waits for a response from MPD.
 *
 * @param {Function} callback
 */
function getData(callback) {
    var data;
    process();

    /**
     * Gets data from the data queue, or waits until something is
     * written.
     */
    function process() {
        if (dataQueue.length) {
            data = dataQueue.shift();

            if (data.match(/^ACK/)) {
                callback(new Error(data));
            }
            else {
                callback(null, data);
            }

            return;
        }

        ev.once('_data', process);
    }
}
