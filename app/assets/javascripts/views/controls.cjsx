# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.controls = {}

{formatTime, parseMPDResponse} = window.APP_LIB
{mpd} = window.MPD_APP


# In order to keep the progress bar of the player up to date, we
# have to keep track of the elapsed time. We don't automatically
# get this value, so we try to update it ourselves. Every once in a
# while we have to check with the server, just to make sure we are
# still in sync.
progressUpdater = null
progressInterval = 15000

components.PlaybackButton = React.createClass
  action: (event) ->
    event.preventDefault()
    mpd this.props.action, (err) ->
      console.error(err) if err

  getClass: -> "glyphicon glyphicon-#{this.props.icon}"

  render: ->
    <a className='player-control' onClick={this.action}>
      <span className={this.getClass()} />
    </a>

components.Controls = React.createClass
  getInitialState: ->
    this.fetchAndSetState()
    return {
      progress: {}
    }

  componentDidMount: ->
    self = this

    # Increases progress while playing.
    setInterval ->
      return unless self.state.state is 'play'

      if self.state.progress
        elapsed = self.state.progress.elapsed || 0

        self.setState
          progress:
            elapsed: elapsed + 1
            duration: self.state.progress.duration
    , 1000

    document.addEventListener 'mpd:changed:player', ->
      self.fetchAndSetState()
    , false

  fetchAndSetState: ->
    self = this

    if progressUpdater isnt null
      clearTimeout progressUpdater
      progressUpdater = null

    mpd 'status', (err, status) ->
      return console.error(err) if err

      data = parseMPDResponse status
      data.progress = {}

      if data.time
        i = data.time.indexOf ':'
        if i > -1
          data.progress.elapsed = Number data.time.substring(0, i)
          data.progress.duration = Number data.time.substring(i + 1)

      self.replaceState data

      if data.state.state is 'play'
        progressUpdater = setTimeout ->
          self.fetchAndSetState()
        , progressInterval

  render: ->
    progress = 0
    playpause =
      if this.state.state isnt 'play'
        <components.PlaybackButton action='play'  icon='play'  />
      else
        <components.PlaybackButton action='pause' icon='pause' />

    if this.state.progress and this.state.progress.duration
      progress = 100 * this.state.progress.elapsed / this.state.progress.duration
      progress = 100 if progress > 100
      progress = 0 unless progress >= 0

    <div>
      <div className="controls-buttons">
        <components.PlaybackButton action='previous' icon='fast-backward' />
        {playpause}
        <components.PlaybackButton action='stop'     icon='stop'          />
        <components.PlaybackButton action='next'     icon='fast-forward'  />
      </div>
      <div className='playing-prog'>
        <div className='playing-prog-bar' style={{width: String(progress) + '%'}}
             role='progressbar'
             aria-valuemin='0'
             aria-valuemax={this.state.progress.duration}
             aria-valuenow={this.state.progress.elapsed}
             >
          <span className='sr-only'>
            {formatTime(this.state.progress.elapsed)} / {formatTime(this.state.progress.duration)}
          </span>
        </div>
      </div>
    </div>

components.Player = React.createClass
  getInitialState: ->
    this.fetchAndSetState()
    return {}

  componentDidMount: ->
    self = this

    document.addEventListener 'mpd:changed', (event) ->
      what =
        if event.detail
          event.detail.what
        else
          null

      if what is 'player' or what is 'playlist'
        self.fetchAndSetState()
    , false

  fetchAndSetState: ->
    self = this
    mpd 'currentsong', (err, currentsong) ->
      return console.error(err) if err
      self.replaceState parseMPDResponse(currentsong)

  render: ->
    <div className='controls-player'>
      <a href='/now_playing' id='currentsong' data-pos={this.state.Pos}>
        {this.state.Artist} - {this.state.Title}
      </a>
    </div>

components.mount = (where) ->
  React.renderComponent(
    <div className='controls-container'>
      <components.Controls />
      <components.Player />
    </div>,
    where
  )


# vim: set ft=coffee:
