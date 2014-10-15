# @cjsx React.DOM

components = window.MPD_APP.views.generics.pagination = {}

components.PaginationItem = Item = React.createClass
  render: ->
    if @props.active
      <li className='active'><span>{@props.label}</span></li>
    else if @props.href
      <li><a href={@props.href}>{@props.label}</a></li>
    else
      <li className='disabled'><span>{@props.label}</span></li>

components.Pagination = React.createClass
  getPrevious: ->
    if @props.pageNo > 1
      <Item key='previous' href={@props.getHref(@props.pageNo - 1)} label='\u00ab' />
    else
      <Item key='previous' label='\u00ab' />

  getNext: ->
    if @props.pageNo < 1 + @props.pageCount
      <Item key='next' href={@props.getHref(@props.pageNo + 1)} label='\u00bb' />
    else
      <Item key='next' label='\u00bb' />

  getFiller: (key) ->
    <Item key={key} label='\u2026' />

  getSinglePage: (i) ->
    <Item key={i} href={@props.getHref i} active={i is @props.pageNo} label={i} />

  getPages: ->
    {start, around, end, pageNo, pageCount} = @props

    start_begin = 1
    start_end = start
    around_begin = pageNo - around
    around_end = pageNo + around
    end_begin = 2 + pageCount - end
    end_end = 1 + pageCount

    if around_begin <= start_end + 1
      start_end = Math.max(around_end, start_end)
      around_begin = around_end = -1

      if start_end + 2 >= end_begin
        start_end = end_end
        end_begin = end_end = -1

    else if start_end + 1 >= end_begin
      start_end = end_end
      around_begin = around_end = -1
      end_begin = end_end = -1

    else if around_end + 1 >= end_begin
      end_begin = Math.min(around_begin, end_begin)
      around_begin = around_end = -1

    pages = []

    pages.push @getPrevious()

    for i in [start_begin..start_end]
      pages.push @getSinglePage(i)

    if around_begin > -1
      pages.push @getFiller('start')
      for i in [around_begin..around_end]
        pages.push @getSinglePage(i)

    if end_begin > -1
      pages.push @getFiller('end')
      for i in [end_begin..end_end]
        pages.push @getSinglePage(i)

    pages.push @getNext()

    return pages

  render: ->
    <ul className='pagination'>
      {@getPages()}
    </ul>
