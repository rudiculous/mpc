# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.routeNotFound = {}
{updateState} = window.MPD_APP

components.RouteNotFound = React.createClass
  render: ->
    <div className='route-not-found'>
      <h1>Not Found</h1>
      <p>The URL you are trying to call was not found.</p>
      <ul>
        <li><a href='/'>Home</a></li>
      </ul>
    </div>

components.mount = (where, req) ->
  updateState
    activeTab: null
    title: 'Not Found'

  React.renderComponent(<components.RouteNotFound />, where)


# vim: set ft=coffee:
