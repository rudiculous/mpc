# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.generics.navigation = {}

components.Dropdown = React.createClass
  render: ->
    <div className='btn-group pull-right main-actions'>
      <button type='button' className='btn btn-default btn-lg btn-primary dropdown-toggle' data-toggle='dropdown'>
        {@props.label} <span className="caret" />
      </button>
      <ul className="dropdown-menu" role="menu">
        {@props.children}
      </ul>
    </div>

components.Action = React.createClass
  render: ->
    <li><a href={@props.href} onClick={@props.onClick}>{@props.children}</a></li>

components.Divider = React.createClass
  render: ->
    <li className='divider' />
