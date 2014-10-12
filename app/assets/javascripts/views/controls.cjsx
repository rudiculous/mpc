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

components.MPDCommandMixin =
  action: (event) ->
    event.preventDefault()

    action =
      if typeof(@getAction) is 'function'
        @getAction()
      else
        @props.action

    args =
      if typeof(@getArgs) is 'function'
        @getArgs()
      else
        null

    if args is null
      mpd action, (err) -> console.error(err) if err
    else
      mpd action, args, (err) -> console.error(err) if err

components.ButtonMixin =
  getClass: -> "glyphicon glyphicon-#{@props.icon}"

components.Button = React.createClass
  componentDidMount: ->
    jQuery(@getDOMNode()).tooltip()

  render: ->
    <a className={@props.className}
       onClick={@props.onClick}
       data-toggle={if @props.title then 'tooltip'}
       title={@props.title}>
      <span className={@props.glyphIcon} />
    </a>

components.UpdateButton = React.createClass
  mixins: [components.MPDCommandMixin, components.ButtonMixin]

  getAction: -> 'update'

  render: ->
    <components.Button className='player-control small' onClick={@action}
                       title='Update Music Database' glyphIcon={@getClass()} />

components.StateButton = React.createClass
  mixins: [components.MPDCommandMixin, components.ButtonMixin]

  getArgs: -> if @props.status is '1' then '0' else '1'

  render: ->
    className = 'player-control small'
    className +=
      if @props.status is '1'
        ' active'
      else
        ' inactive'

    <components.Button className={className} onClick={@action}
                       title={@props.title} glyphIcon={@getClass()} />

components.PlaybackButton = React.createClass
  mixins: [components.MPDCommandMixin, components.ButtonMixin]

  render: ->
    className = 'player-control'
    className += ' small' if @props.small

    <components.Button className={className} onClick={@action}
                       title={@props.title} glyphIcon={@getClass()} />

components.Controls = React.createClass
  getInitialState: ->
    @fetchAndSetState()
    return {
      progress: {}
    }

  componentDidMount: ->
    self = @

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

    document.addEventListener 'mpd:changed', (event) ->
      if event.detail
        {what} = event.detail
      else
        what = null

      if what is 'player' or what is 'options'
        self.fetchAndSetState()
    , false

  fetchAndSetState: ->
    self = @

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
      if @state.state isnt 'play'
        <components.PlaybackButton action='play'  icon='play'  />
      else
        <components.PlaybackButton action='pause' icon='pause' />

    if @state.progress and @state.progress.duration
      progress = 100 * @state.progress.elapsed / @state.progress.duration
      progress = 100 if progress > 100
      progress = 0 unless progress >= 0

    <div>
      <div className='controls-buttons'>
        <components.PlaybackButton action='previous' icon='fast-backward' />
        {playpause}
        <components.PlaybackButton action='stop'     icon='stop'          />
        <components.PlaybackButton action='next'     icon='fast-forward'  />
      </div>
      <div className=''>
        <components.StateButton action='repeat'  icon='repeat'   status={@state.repeat}  title='Repeat Playlist' />
        <components.StateButton action='random'  icon='random'   status={@state.random}  title='Play Tracks In Random Order' />
        <components.StateButton action='consume' icon='trash'    status={@state.consume} title='Consume Tracks After Playing' />
        <components.StateButton action='single'  icon='asterisk' status={@state.single}  title='Play a Single Track' />
        <components.UpdateButton icon='refresh' />
      </div>
      <div className='playing-prog'>
        <div className='playing-prog-bar' style={{width: String(progress) + '%'}}
             role='progressbar'
             aria-valuemin='0'
             aria-valuemax={@state.progress.duration}
             aria-valuenow={@state.progress.elapsed}
             >
          <span className='sr-only'>
            {formatTime(@state.progress.elapsed)} / {formatTime(@state.progress.duration)}
          </span>
        </div>
      </div>
    </div>

components.Player = React.createClass
  getInitialState: ->
    @fetchAndSetState()
    return {}

  componentDidMount: ->
    self = @

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
    self = @
    mpd 'currentsong', (err, currentsong) ->
      return console.error(err) if err
      self.replaceState parseMPDResponse(currentsong)

  render: ->
    <div className='controls-player'>
      <a href='/now_playing' id='currentsong' data-pos={@state.Pos}>
        {@state.Artist} - {@state.Title}
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
