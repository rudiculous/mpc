# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.search = {}

{parseMPDResponse} = window.APP_LIB
{mpd, updateState} = window.MPD_APP
{Directory, File} = window.MPD_APP.views.generics.items

components.SearchResults = React.createClass
  getInitialState: ->
    @fetchAndSetState()
    return {
      loading: true
      entries: []
    }

  fetchAndSetState: ->
    search = @props.search
    search.replace /[\n\r]/g, ' ' # Strip newlines.
    search.replace /([\\"])/g, '\\$1' # Escape characters.
    search = '"' + search + '"'

    mpd 'search', 'any', search, (err, results) =>
      if err
        @setState
          loading: false
          error: err
        return console.error err

      count = 0
      data = {}

      data.entries = parseMPDResponse results,
        file: (entry) ->
          <File entry={entry} key={count++} />

      @replaceState data

  render: ->
    contents = (
      if @state.loading
        <div className='alert alert-info'>Loading&hellip;</div>
      else if @state.error
        <div className='alert alert-danger'>
          <strong>An error occurred!</strong>
          <pre>{@state.error}</pre>
        </div>
      else if not @state.entries.length
        <div className='alert alert-warning'><strong>No results found.</strong></div>
      else
        <table className='playlist table table-striped table-condensed table-hover'>
          <col style={{width: '400px'}} />
          <col style={{width: '50px'}} />
          <col />
          <col style={{width: '70px'}} />

          <thead>
            <th>Artist - Album</th>
            <th>Track</th>
            <th>Title</th>
            <th>Duration</th>
          </thead>

          <tfoot />

          <tbody>{@state.entries}</tbody>
        </table>
    )

    <div className='search-results'>
      <h1>Search Results for <em>{@props.search}</em></h1>
      {contents}
    </div>

components.mount = (where, req) ->
  {search} = req.params

  search =
    if Array.isArray(search) and search.length
      search[0]
    else
      ''

  updateState
    activeTab: null
    title: "Search Results for '#{search}'"

  React.renderComponent(
    <components.SearchResults search={search} />,
    where
  )


# vim: set ft=coffee:
