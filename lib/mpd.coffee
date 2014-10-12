"use strict"

# # Initialization

MPD_HOST = process.env.MPD_HOST || 'localhost'
MPD_PORT = process.env.MPD_PORT || 6600

net = require 'net'
{EventEmitter} = require 'events'

client = null
queue = []
dataQueue = []
mpdStatus = null
ev = new EventEmitter()

ev.setMaxListeners 0

commandList = [
  # [Querying MPD's status.](http://www.musicpd.org/doc/protocol/command_reference.html)
  'currentsong', 'status', 'stats',

  # [Playback options.](http://www.musicpd.org/doc/protocol/playback_option_commands.html)
  'consume', 'crossfade', 'mixrampdb', 'mixrampdelay', 'random',
  'repeat', 'setvol', 'single', 'replay_gain_mode',
  'replay_gain_status', 'volume',

  # [Controlling playback.](http://www.musicpd.org/doc/protocol/playback_commands.html)
  'next', 'pause', 'play', 'playid', 'previous', 'seek', 'seekid',
  'seekcur', 'stop',

  # [The current playlist.](http://www.musicpd.org/doc/protocol/queue.html)
  'add', 'addid', 'clear', 'delete', 'deleteid', 'move', 'moveid',
  'playlist', 'playlistfind', 'playlistid', 'playlistinfo',
  'playlistsearch', 'plchanges', 'plchangesposid', 'prio', 'prioid',
  'rangeid', 'shuffle', 'swap', 'swapid', 'addtagid', 'cleartagid',

  # [Stored playlists.](http://www.musicpd.org/doc/protocol/playlist_files.html)
  'listplaylist', 'listplaylistinfo', 'listplaylists', 'load',
  'playlistadd', 'playlistclear', 'playlistdelete', 'playlistmove',
  'rename', 'rm', 'save',

  # [The music database.](http://www.musicpd.org/doc/protocol/database.html)
  'count', 'find', 'findadd', 'list', 'listall', 'listallinfo',
  'listfiles', 'lsinfo', 'readcomments', 'search', 'searchadd',
  'searchaddpl', 'update', 'rescan',
]

validCommands = {}
commandList.forEach (command) -> validCommands[command] = true

# # Public API

# Returns a deep copy of the command list.
exports.getCommandList = -> JSON.parse(JSON.stringify(commandList))


# ## Event handlers

exports.on = ->
  ev.on.apply ev, arguments
  return

exports.once = ->
  ev.once.apply ev, arguments
  return

exports.removeListener = ->
  ev.removeListener.apply ev, arguments
  return


# ## Connection

# Cleans up after the connection gets closed.
cleanup = ->
  client = null
  queue.length = 0
  dataQueue.length = 0
  mpdStatus = null
  ev.removeListener 'queue:updated', queueUpdatedHandler

  # Remove *all* listeners on the _data event.
  ev.removeAllListeners '_data'

# Connects to MPD.
#
# @param {Number} [port]
# @param {String} [host]
exports.connect = (port, host) ->
  port = MPD_PORT if arguments.length < 1
  host = MPD_HOST if arguments.length < 2

  if client is null
    queue.length = 0
    dataQueue.length = 0
    mpdStatus = null

    try
      client = net.connect
        port: port
        host: host
      , ->
        ev.once '_data', ->
          # The first data coming back is the `OK MPD version` line
          mpdStatus = dataQueue.shift()
          client.write 'idle\n', -> ev.emit 'connection:ready'
    catch err
      ev.emit 'connection:error', err
      cleanup()
      return

    client.on 'error', (err) ->
      ev.emit 'connection:error', err
      cleanup()
      return

    client.on 'data', (data) ->
      data = data.toString 'utf8'
      #process.stdout.write data

      matched = data.match /^changed: ([^\r\n]*)/

      if matched
        ev.emit 'changed', matched[1]
        client.write 'idle\n'
      else
        dataQueue.push data
        ev.emit '_data'

    ev.once 'queue:updated', queueUpdatedHandler

    client.on 'end', ->
      cleanup()
      ev.emit 'connection:closed'
  else
    ev.emit 'connection:error', new Error('Connection already open/')

  return

# Closes the connection to MPD.
exports.close = exports.end = ->
  client.end() if client isnt null
  return

# Pushes a command onto the queue.
#
# @param {String}    command
# @param {String...} args
# @param {Function}  callback
exports.push = (command, args..., callback) ->
  last = arguments.length - 1

  if typeof(callback) isnt 'function'
    return # Not doing anything without a callback.

  if arguments.length < 2
    return callback new Error('Invalid number of arguments.')

  args = args.join(' ').replace('\n', '')
  args = ' ' + args unless args is ''

  unless validCommands[command]
    return callback new Error('Invalid command.')

  queue.push
    command: command
    args: args
    callback: callback

  setTimeout ->
    ev.emit 'queue:updated'
  , 0

  return

# # Private methods

# Wrapper method for shift. This can be used in event handlers, as any
# arguments are not passed along to shift.
queueUpdatedHandler = -> shift()

# Shifts a command from the queue and executes it.
#
# If, after finishing the command, there are more commands on the
# queue, these commands are also executed. When there are no commands
# left, the `idle` command is sent.
#
# @param {Boolean} [skipNoIdle=false]
shift = (skipNoIdle = false) ->

  # If shift was not called with `skipNoIdle`, it means we could
  # still be idle. If so, pass `onlyIfSkipNoIdle` to not write a new
  # `idle` command.
  done = (onlyIfSkipNoIdle) ->
    if queue.length
      shift true
    else unless !skipNoIdle && onlyIfSkipNoIdle
      # Nothing left to do, wait for more input.
      client.write 'idle\n'
      ev.once 'queue:updated', queueUpdatedHandler

  act = ->
    client.write command + args + '\n', ->
      getData ->
        callback.apply this, arguments
        done()

  return if client is null
  return done(true) unless queue.length

  item = queue.shift()

  unless item
    # No item?
    console.trace 'Empty item was pushed onto the queue!', item

  {command, args, callback} = item

  if skipNoIdle
    act()
  else
    client.write 'noidle\n', -> getData(act)

  return


# Waits for a response from MPD.
#
# @param {Function} callback
getData = (callback) ->

  # Gets data from the data queue, or waits until something is
  # written.
  process = ->
    if dataQueue.length
      data = dataQueue.shift()

      if data.match /^ACK/
        callback new Error(data)
      else
        callback null, data

      return

    ev.once '_data', process

  process()
