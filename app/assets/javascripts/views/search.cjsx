# @cjsx React.DOM

"use strict"

RPP = 50
PAG_AT_START = 5
PAG_AT_END = 5
PAG_AROUND = 3

components = window.MPD_APP.views.search = {}

{parseMPDResponse} = window.APP_LIB
{mpd, updateState} = window.MPD_APP
{Directory, File} = window.MPD_APP.views.generics.items
{Pagination} = window.MPD_APP.views.generics.pagination
{Dropdown, Action, Divider} = window.MPD_APP.views.generics.navigation

components.SearchResults = React.createClass
  getInitialState: ->
    @fetchAndSetState()
    return {
      loading: true
      entries: []
      resultCount: 0
    }

  fetchAndSetState: ->
    search = @props.search
    search = search.replace /[\n\r]/g, ' ' # Strip newlines.
    search = search.replace /([\\"])/g, '\\$1' # Escape characters.
    search = '"' + search + '"'

    mpd 'search', 'any', search, (err, results) =>
      if err
        @setState
          loading: false
          error: err
        return console.error err

      count = 0
      data = {}

      [data.entries, data.resultCount] = parseMPDResponse results,
        file: (entry) ->
          <File entry={entry} key={count++} />
      , null, @props.pageNo - 1, RPP

      @replaceState data

  getPageNoUrl: (pageNo) ->
    base = document.location.search.replace /([?&;]pageNo=[^&;]*)/, ''

    if base
      base + "&pageNo=#{pageNo}"
    else
      "?pageNo=#{pageNo}"

  render: ->
    pagination = ''

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
        pagination = (
          <Pagination
            start={PAG_AT_START}
            around={PAG_AROUND}
            end={PAG_AT_END}
            pageNo={@props.pageNo}
            pageCount={@state.resultCount // RPP}
            getHref={@getPageNoUrl} />
        )

        <div>
          {pagination}
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
          {pagination}
        </div>
    )

    <div className='search-results'>
      <header className='clearfix'>
        <Dropdown label='Actions'>
          <Action href='#'>Add to playlist...</Action>
        </Dropdown>
        <h1>Search Results for <em>{@props.search}</em></h1>
      </header>
      {contents}
    </div>

components.mount = (where, req) ->
  {search, pageNo} = req.params

  search =
    if Array.isArray(search) and search.length
      search[0]
    else
      ''

  pageNo ?= 1
  pageNo = Number(pageNo)

  updateState
    activeTab: null
    title: "Search Results for '#{search}'"

  React.renderComponent(
    <components.SearchResults search={search} pageNo={pageNo} />,
    where
  )


# vim: set ft=coffee:
