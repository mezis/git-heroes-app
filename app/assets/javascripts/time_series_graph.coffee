# originally taken from
# http://bl.ocks.org/mbostock/3883245
class TimeSeriesGraph
  constructor: (@el) ->
    @parseDate = d3.time.format('%Y-%m-%d').parse
    $(window).resize =>
      this.render()
  
  fetch: ->
    d3.json $(@el).data('url'), (error, data) =>
      @data =  this.parser(data)
      this.render()

  parser: (data) ->
    data.map (d) =>
      date:   @parseDate(d[0])
      points: +d[1]

  timeFormat: ->
    d3.time.format.multi [
      ["%a %d", (d) -> (d.getDay() && d.getDate() != 1)]
      ["%b %d", (d) -> (d.getDate() != 1)]
      ["%b", (d) -> d.getMonth()]
      ["%Y", (d) -> true]
    ]

  formatDate: (d) ->
    @_formatDate ||= d3.time.format("%A, %e %b %Y")
    @_formatDate(d)

  render: ->
    return unless @data?
    $(@el).empty()

    width = $(@el).width()
    height = width * 2/3
    padding = 1

    x = d3.time.scale()
      .range([0, width-2*padding])
    y = d3.scale.linear()
      .range([height,2*padding])

    color = d3.scale.category10()
    xAxis = d3.svg.axis()
      .scale(x)
      .orient('top')
      .tickFormat(this.timeFormat())
      .ticks(d3.min([10, width/50]))
    yAxis = d3.svg.axis()
      .scale(y)
      .orient('right')
      .ticks(d3.min([10, height/30]))
    line = d3.svg.line()
      .interpolate('cardinal')
      .x((d) ->
        x d.date
      ).y((d) ->
        y d.y
      )

    svg = d3.select(@el)
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('transform', "translate(#{padding},-#{padding})")

    color.domain d3.keys(@data[0]).filter((key) ->
      key != 'date'
    )

    series = color.domain().map (name) =>
      name: name
      values: @data.map((d) ->
        date:  d.date
        y:     d[name]
      )
    x.domain d3.extent(@data, (d) ->
      d.date
    )
    y.domain [
      d3.min(series, (c) ->
        d3.min c.values, (v) ->
          v.y
      )
      d3.max(series, (c) ->
        d3.max c.values, (v) ->
          v.y
      )
    ]

    # The actual curves
    graph = svg.selectAll('.line')
      .data(series)
      .enter()
      .append('g')
      .attr('class', 'line')
    graph.append('path')
      .attr('class', 'graph-line')
      .attr('d', (d) ->
        line d.values
      ).style('stroke', (d) ->
        color d.name
      )
    
    # Axes
    svg.append('g')
      .attr('class', 'graph-axis graph-axis--x')
      .attr('transform', 'translate(0,' + height + ')')
      .call xAxis
    svg.append('g')
      .attr('class', 'graph-axis graph-axis--y')
      .call(yAxis)

    flatData = d3.merge @data.map (d) ->
      color.domain().map (name) ->
        name: name
        date: d.date
        y:    d[name]

    # Circles
    circles = svg.append('g')
      .selectAll('.circle')
      .data(flatData)
      .enter()
      .append('g')
      .attr('class', 'circle')
    circles.append('svg:circle')
      .attr('class', 'graph-point')
      .attr('r', 10)
      .attr('cx', (d) ->
        x d.date
      )
      .attr('cy', (d) ->
        y d.y
      )
      .attr('title', (d) =>
        """
          <small>#{this.formatDate(d.date)}</small>
          <br/>
          <strong>#{d3.round d.y, 1}</strong> #{d.name}
        """
      )
      .attr('data-toggle', 'tooltip')

    Heroes.dispatch "tooltip:update", target: @el
    return

$(document).on "page:change", ->
  $('.graph-timeseries').each (idx, el) ->
    new TimeSeriesGraph(el).fetch()
