# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.nowPlaying = {}
{updateState, mpd} = window.MPD_APP
{formatTime, parseMPDResponse} = window.APP_LIB

components.SingleEntry = React.createClass
  clickHandler: ->
    if this.props.song.Pos
      mpd 'play', this.props.song.Pos, (err) ->
        console.error if err

  render: ->
    {Artist, Album, Track, Title, Time} = this.props.song

    active =
      if this.props.active
        {}
      else
        {display:'none'}

    <tr className={this.props.active ? 'now-playing' : ''} onClick={this.clickHandler}>
      <td style={{'text-align':'center'}}><span className='glyphicon glyphicon-play' style={active} /></td>
      <td>{Artist} - {Album}</td>
      <td style={{'text-align':'right'}}>{Track}</td>
      <td>{Title}</td>
      <td style={{'text-align':'right'}}>{formatTime(Time)}</td>
    </tr>

components.NowPlaying = React.createClass
  getInitialState: ->
    this.fetchAndSetState()
    return {
      songs: []
    }

  cleanUpHandlers: ->
    if this.__mpdChangedHandler
      document.removeEventListener 'mpd:changed', this.__mpdChangedHandler
      delete this.__mpdChangedHandler

  componentDidMount: ->
    self = this

    this.cleanUpHandlers()

    this.__mpdChangedHandler = (event) ->
      what =
        if event.detail
          event.detail.what
        else
          null

      if what is 'player' or what is 'playlist'
        self.fetchAndSetState()

    document.addEventListener 'mpd:changed', this.__mpdChangedHandler, false

  componentWillUnmount: -> this.cleanUpHandlers()

  fetchAndSetState: ->
    self = this

    currentsong = document.getElementById 'currentsong'

    mpd 'playlistinfo', (err, playlistinfo) ->
      return console.error(err) if err

      data = {}

      data.songs = parseMPDResponse playlistinfo,
        file: (entry) ->
          active = currentsong and currentsong.dataset and currentsong.dataset.pos is entry.Pos

          <components.SingleEntry key={entry.Pos} song={entry} active={active} />

      self.replaceState data

  render: ->
    <div className='now-playing'>
      <h1>Now Playing</h1>
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

        <tbody>{this.state.songs}</tbody>
      </table>
    </div>

components.mount = (where, req) ->
  updateState
    activeTab: 'now_playing'
    title: 'Now Playing'

  React.renderComponent <components.NowPlaying />, where


# vim: set ft=coffee:
