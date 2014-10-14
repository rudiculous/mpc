# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.generics.items = {}

{formatTime} = window.APP_LIB

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
