# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.nowPlaying = {}
{updateState, mpd} = window.MPD_APP
{formatTime, parseMPDResponse} = window.APP_LIB
{Dropdown, Action, Divider} = window.MPD_APP.views.generics.navigation

components.SingleEntry = React.createClass
  clickHandler: ->
    if @props.song.Pos
      mpd 'play', @props.song.Pos, (err) ->
        console.error if err

  render: ->
    {Artist, Album, Track, Title, Time} = @props.song

    active =
      if @props.active
        {}
      else
        {display:'none'}

    <tr className={if @props.active then 'currently-playing' else ''} onClick={@clickHandler}>
      <td style={{'text-align':'center'}}><span className='glyphicon glyphicon-play' style={active} /></td>
      <td>{Artist} - {Album}</td>
      <td style={{'text-align':'right'}}>{Track}</td>
      <td>{Title}</td>
      <td style={{'text-align':'right'}}>{formatTime(Time)}</td>
    </tr>

components.NowPlaying = React.createClass
  getInitialState: ->
    @fetchAndSetState()
    return {
      songs: []
    }

  cleanUpHandlers: ->
    if @__mpdChangedHandler
      document.removeEventListener 'mpd:changed', @__mpdChangedHandler
      delete @__mpdChangedHandler

  componentDidMount: ->
    @cleanUpHandlers()

    @__mpdChangedHandler = (event) =>
      what =
        if event.detail
          event.detail.what
        else
          null

      if what is 'player' or what is 'playlist'
        @fetchAndSetState()

    document.addEventListener 'mpd:changed', @__mpdChangedHandler, false

  componentWillUnmount: -> @cleanUpHandlers()

  fetchAndSetState: ->
    currentsong = document.getElementById 'currentsong'

    mpd 'playlistinfo', (err, playlistinfo) =>
      return console.error(err) if err

      data = {}

      data.songs = parseMPDResponse playlistinfo,
        file: (entry) ->
          active = currentsong and currentsong.dataset and currentsong.dataset.pos is entry.Pos

          <components.SingleEntry key={entry.Pos} song={entry} active={active} />

      @replaceState data

  clear: (event) ->
    event.preventDefault()
    mpd 'clear', (err, playlistinfo) =>
      return console.error(err) if err

  render: ->
    <div className='now-playing'>
      <header className='clearfix'>
        <Dropdown label='Actions'>
          <Action onClick={@clear}>Clear playlist</Action>
        </Dropdown>
        <h1>Now Playing</h1>
      </header>

      <table className='playlist table table-striped table-condensed table-hover'>
        <col style={{width: '65px'}} />
        <col style={{width: '400px'}} />
        <col style={{width: '50px'}} />
        <col />
        <col style={{width: '70px'}} />

        <thead>
          <th>Playing</th>
          <th>Artist - Album</th>
          <th>Track</th>
          <th>Title</th>
          <th>Duration</th>
        </thead>

        <tfoot />

        <tbody>{@state.songs}</tbody>
      </table>
    </div>

components.mount = (where, req) ->
  updateState
    activeTab: 'now_playing'
    title: 'Now Playing'

  React.renderComponent <components.NowPlaying />, where


# vim: set ft=coffee:
