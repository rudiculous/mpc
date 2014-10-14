# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.navigation = {}

components.Item = React.createClass
  getInitialState: -> history.state || {}

  componentDidMount: ->
    document.addEventListener 'state:updated', =>
      @replaceState(history.state || {})
    , false

  render: ->
    className = 'navigation-menu-item'
    className += ' active' if @state.activeTab is @props.key

    <li className={className}>
      <a href={@props.href}>{@props.label}</a>
    </li>

components.Menu = React.createClass
  render: ->
    <div>
      <ul className='navigation-menu nav nav-pills nav-stacked'>
        <components.Item href='/now_playing' label='Now Playing' key='now_playing' />
        <components.Item href='/file_browser' label='File Browser' key='file_browser' />
      </ul>

      <form className='navigation-menu nav nav-pills nav-stacked' role='search' action='/search' method='get'>
        <div className='input-group'>
          <input type='text' className='form-control' name='search' placeholder='search' />
          <span className='input-group-btn'>
            <button className='btn btn-default' type='submit'>
              <span className='glyphicon glyphicon-search' />
            </button>
          </span>
        </div>
      </form>
    </div>

components.mount = (where) ->
  React.renderComponent(<components.Menu />, where)


# vim: set ft=coffee:
