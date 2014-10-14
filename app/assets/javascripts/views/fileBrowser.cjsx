# @cjsx React.DOM

"use strict"

components = window.MPD_APP.views.fileBrowser = {}

{parseMPDResponse} = window.APP_LIB
{mpd, updateState} = window.MPD_APP
{Directory, File} = window.MPD_APP.views.generics.items

components.FileBrowser = React.createClass
  getInitialState: ->
    @fetchAndSetState()
    return {
      loading: true
      entries: []
      files: []
      directories: []
    }

  fetchAndSetState: ->
    mpd 'lsinfo', @props.pathName, (err, playlistinfo) =>
      if err
        @setState
          loading: false
          error: err
        return console.error err

      count = 0
      data =
        directories: []
        files: []

      data.entries = parseMPDResponse playlistinfo,
        file: (entry) ->
          file = <File entry={entry} key={count++} />
          data.files.push file
          return file
        directory: (entry) ->
          directory = <Directory entry={entry} key={count++} />
          data.directories.push directory
          return directory

      @replaceState data

  render: ->
    crumbs = []
    crumbCount = 0
    {pathName} = @props
    pathSoFar = ''

    if pathName
      crumbs.push <li key={crumbCount++}><a href='/file_browser'>home</a></li>

      segments = pathName.split '/'
      for segment, i in segments
        pathSoFar += '/' if pathSoFar isnt ''
        pathSoFar += segment

        crumbs.push(
          if i < segments.length - 1
            <li key={crumbCount++}>
              <a href={"/file_browser?pathName=#{encodeURIComponent pathSoFar}"}>{segment}</a>
            </li>
          else
            <li key={crumbCount++} className='active'>{segment}</li>
        )
    else
      crumbs.push(
        <li key={crumbCount++} className='active'>home</li>
      )

    contents = (
      if @state.loading
        <div className='alert alert-info'>Loading&hellip;</div>
      else if @state.error
        <div className='alert alert-danger'>
          <strong>An error occurred!</strong>
          <pre>{@state.error}</pre>
        </div>
      else
        directories = (
          if @state.directories.length
            <div>
              <h2>Directories</h2>
              <ul className='list-group'>
                {@state.directories}
              </ul>
            </div>
          else
            ''
        )

        files = (
          if @state.files.length
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

              <tbody>{@state.files}</tbody>
            </table>
          else
            <p>No filed found.</p>
        )

        <div>
          {directories}
          <h2>Files</h2>
          {files}
        </div>
    )

    return (
      <div className='music-file-browser'>
        <h1>File Browser</h1>
        <ol className='breadcrumb'>{crumbs}</ol>
        {contents}
      </div>
    )

components.mount = (where, req) ->
  {pathName} = req.params

  pathName =
    if Array.isArray(pathName) and pathName.length
      pathName[0]
    else
      ''

  updateState
    activeTab: 'file_browser'
    title: 'File Browser'

  React.renderComponent(
    <components.FileBrowser pathName={pathName} />,
    where
  )


# vim: set ft=coffee:
