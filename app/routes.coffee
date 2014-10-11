"use strict"

app = require './core/app'

app.io.on 'connection', (socket) ->
  changedHandler = (message) -> socket.emit 'mpd:changed', message

  # add listeners
  app.mpd.on 'changed', changedHandler

  socket.on 'mpd:command', (data, callback) ->
    if data and data.command
      {command, args} = data

      args = [] unless Array.isArray args

      args.unshift command
      args.push (err, res) ->
        if callback and typeof(callback) is 'function'
          if err
            err =
              if err.message
                'error: ' + err.message
              else
                'unknown error'
          callback(err, res)

      app.mpd.push.apply null, args
  
  socket.on 'disconnect', -> app.mpd.removeListener 'changed', changedHandler

  socket.emit 'socket:ready'
