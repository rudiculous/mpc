# @cjsx React.DOM

"use strict"

RPP = 50
PAG_AT_START = 5
PAG_AT_END = 5
PAG_AROUND = 3

components = window.MPD_APP.views.search = {}

{parseMPDResponse, mpdSafe} = window.APP_LIB
{mpd, updateState} = window.MPD_APP
{Playlist, Directory, File} = window.MPD_APP.views.generics.items
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
    search = mpdSafe @props.search

    mpd 'search', 'any', search, (err, results) =>
      if err
        @setState
          loading: false
          error: err
        return console.error err

      count = 0
      data = {}
      data.totalTime = 0

      [data.entries, data.resultCount] = parseMPDResponse results,
        file: (entry) ->
          data.totalTime += Number(entry.Time)
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
    contents = (
      if @state.loading
        <div className='alert alert-info'>Loading&hellip;</div>
      else if @state.error
        <div className='alert alert-danger'>
          <strong>An error occurred!</strong>
          <pre>{@state.error}</pre>
        </div>
      else if @state.resultCount < 1
        <div className='alert alert-warning'><strong>No results found.</strong></div>
      else
        pagination = (
          <Pagination
            start={PAG_AT_START}
            around={PAG_AROUND}
            end={PAG_AT_END}
            pageNo={@props.pageNo}
            pageCount={(@state.resultCount - 1) // RPP}
            getHref={@getPageNoUrl} />
        )

        <div>
          {pagination}
          <Playlist totalTime={@state.totalTime}>
            {@state.entries}
          </Playlist>
          {pagination}
        </div>
    )

    h1Extra = (
      if @state.resultCount > 0
        <small>{@state.resultCount} results</small>
      else
        ''
    )

    <div className='search-results'>
      <header className='clearfix'>
        <Dropdown label='Actions'>
          <Action href='#'>Add to playlist...</Action>
        </Dropdown>
        <h1>Search Results for <em>{@props.search}</em> {h1Extra}</h1>
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
