# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.generics.items = {}

{formatTime} = window.APP_LIB

components.Playlist = React.createClass
  render: ->
    <table className='playlist table table-striped table-condensed table-hover'>
      <col style={{width: '400px'}} />
      <col style={{width: '50px'}} />
      <col />
      <col style={{width: '70px'}} />

      <thead>
        <tr>
          <th>Artist - Album</th>
          <th>Track</th>
          <th>Title</th>
          <th>Duration</th>
        </tr>
      </thead>

      <tfoot>
        <tr>
          <th colSpan='3'>{@props.children.length} songs</th>
          <th style={{'text-align': 'right'}}>{formatTime @props.totalTime}</th>
        </tr>
      </tfoot>

      <tbody>{@props.children}</tbody>
    </table>

components.Directory = React.createClass
  contextMenu: (event) ->
    event.preventDefault()

  render: ->
    {directory} = @props.entry
    segments = directory.split '/'
    lastSegment = segments[segments.length - 1]

    <li onContextMenu={@contextMenu} className='list-group-item'>
      <a href={"/file_browser?pathName=#{encodeURIComponent directory}"}>
        {lastSegment}
      </a>
    </li>

components.File = React.createClass
  render: ->
    {Artist, Album, Track, Title, Time} = @props.entry

    <tr>
      <td>{Artist} - {Album}</td>
      <td style={{'text-align':'right'}}>{Track}</td>
      <td>{Title}</td>
      <td style={{'text-align':'right'}}>{formatTime(Time)}</td>
    </tr>


# vim: set ft=coffee:
