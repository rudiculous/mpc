# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.navigation = {}

components.Item = React.createClass
  getInitialState: -> history.state || {}

  componentDidMount: ->
    self = this
    document.addEventListener 'state:updated', ->
      self.replaceState(history.state || {})
    , false

  render: ->
    className = 'navigation-menu-item'
    className += ' active' if this.state.activeTab is this.props.key

    <li className={className}>
      <a href={this.props.href}>{this.props.label}</a>
    </li>

components.Menu = React.createClass
  render: ->
    <ul className='navigation-menu nav nav-pills nav-stacked'>
      <components.Item href='/now_playing' label='Now Playing' key='now_playing' />
      <components.Item href='/file_browser' label='File Browser' key='file_browser' />
    </ul>

components.mount = (where) ->
  React.renderComponent(<components.Menu />, where)


# vim: set ft=coffee:
