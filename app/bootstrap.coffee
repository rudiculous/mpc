"use strict"

# Dependencies
app = exports = module.exports = require './core/app'

require './routes'

# Serve-static middleware allows Express to serve static files.
if app.config.middleware['serve-static']
  serveStatic = require 'serve-static'
  serveIndex = require 'serve-index'

  # Serve files from /static.
  staticSource = __dirname.replace(/app\/?$/, 'static')
  app.logger.info 'Using serve-static middleware (serving from %s).', staticSource
  app.use '/static', serveStatic(staticSource)

  # Serve files from /doc.
  docSource = __dirname.replace(/app\/?$/, 'doc')
  app.logger.info 'Using serve-index and serve-static middleware (serving from %s).', docSource
  app.use '/doc', serveStatic(docSource), serveIndex(docSource)

# Errorhandler middleware shows useful error pages when an error occurs.
if app.config.middleware['errorhandler']
  app.logger.info 'Using errorhandler middleware'
  app.use require('errorhandler')()

# Route all remaining URI's to the index.
app.get '*', (req, res) -> res.render 'index'
