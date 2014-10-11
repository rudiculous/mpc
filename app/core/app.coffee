"use strict"

# # Dependencies
fs = require 'fs'
http = require 'http'
pathM = require 'path'

bodyParser = require 'body-parser'
express = require 'express'
io = require 'socket.io'
swig = require 'swig'
rdclMiddleware = require 'rdcl-middleware'

# # Initialization
root = pathM.join __dirname, '../../'
app = exports = module.exports = express()

settings = require '../../settings'
app.config = settings.config

app.logger = new rdclMiddleware.Logger()
app.use bodyParser.json()
app.enable 'trust proxy'

app.server = http.Server(app)
app.listen = app.server.listen.bind(app.server)

app.io = io(app.server)
app.mpd = require '../../lib/mpd'
app.mpd.connect app.config.mpd.port, app.config.mpd.host


# If the connection to MPD gets lost, we try to reestablish the
# connection. To prevent spamming, we wait a little longer between each
# attempt (up to a certain maximum).
retryAfter =
  initial: 250
  incr: 250
  max: 5000
retryAfter.val = retryAfter.initial

reconnectMPD = (err) ->
  if err
    app.logger.error 'MPD connection lost: %s', err.message
  else
    app.logger.warning 'MPD connection lost'

  setTimeout ->
    retryAfter.val += retryAfter.incr if retryAfter.val < retryAfter.max
    app.logger.info 'Trying to reestablish MPD connection.'
    app.mpd.connect app.config.mpd.port, app.config.mpd.host
  , retryAfter.val

app.mpd.on 'connection:closed', reconnectMPD
app.mpd.on 'connection:error', reconnectMPD
app.mpd.on 'connection:ready', ->
  retryAfter.val = retryAfter.initial
  app.logger.info 'Successfully connected to MPD.'


# ## Template engine
templateRoot = pathM.join root, 'app/templates'
swig.setDefaults
  loader: new rdclMiddleware.TemplateLoader(templateRoot)
app.engine 'swig.html', swig.renderFile
app.set 'view engine', 'swig.html'
app.set 'views', templateRoot

# ## Assets
if settings.environment is 'production'
  assets = rdclMiddleware.assets
    environment: 'production'
    root: root
    assetsBaseURI: settings.config.locals.staticBase + '/assets'
    manifest: require '../../static/assets/manifest'
  app.use assets
else
  assets = rdclMiddleware.assets
    environment: 'development'
    root: root
    assetsBaseURI: '/assets'
    manifest: require '../assets/manifest'
  app.use assets
  app.use '/assets', assets.serveAssets

# Set locals. Locals are made available to the template parser.
Object.keys(settings.config.locals).forEach (key) ->
  app.locals[key] = settings.config.locals[key]
