# originally take from
# http://bl.ocks.org/mbostock/2368837

class LeaderboardGraph
  constructor: (@el) ->
    $(window).resize =>
      this.render()
  
  fetch: ->
    d3.csv $(@el).data('url'), this.parser, (error, data) =>
      @data = data
      this.render()

  parser: (d) ->
    d.points = +d.points
    d

  maxTextWidth: (labels) ->
    tmp = d3.select(@el).append('svg').attr('width', 100).attr('height', 100)
    lengths = labels.map (l) ->
      tmp.append('text')
        .attr('class', 'graph-label')
        .text(l)[0][0]
        .getBBox().width
    tmp.remove()
    d3.max(lengths)

  render: ->
    return unless @data?
    $(@el).empty()

    labels = @data.map (d) ->
      d.user
    values = @data.map (d) ->
      d.points

    containerWidth = $(@el).width()
    barHeight = 20
    barGap = 5
    labelOffset = 10
    groupHeight = barHeight * @data.length
    spaceForLabels = this.maxTextWidth(labels) + labelOffset
    chartWidth = containerWidth - spaceForLabels

    chartHeight = barHeight * labels.length - barGap
    x = d3.scale.linear()
      .domain([0, d3.max(values)])
      .range([0, chartWidth])
    y = d3.scale.linear()
      .range([chartHeight, 0])

    yAxis = d3.svg.axis().scale(y).tickFormat('').tickSize(0).orient('left')

    # Specify the chart area and dimensions
    chart = d3.select(@el)
      .append('svg')
      .attr('width', spaceForLabels + chartWidth)
      .attr('height', chartHeight)

    # Create bars
    bar = chart.selectAll('g')
      .data(values)
      .enter()
      .append('g')
      .attr('transform', (d, i) ->
        'translate(' + spaceForLabels + ',' + i * barHeight + ')'
      )

    # Create rectangles of the correct width
    bar.append('rect')
      .attr('class', 'graph-bar')
      .attr('width', x)
      .attr('height', barHeight - barGap)

    # Add text label in bar
    bar.append('text')
      .attr('class', 'graph-value')
      .attr('x', (d) ->
        x(d) - 3
      )
      .attr('y', (barHeight-barGap)/2)
      .text (d) ->
        d

    # Draw labels
    bar.append('text')
      .attr('class', 'graph-label')
      .attr('x', (d) ->
        -labelOffset
      )
      .attr('y', (barHeight-barGap)/2)
      .text (d, i) ->
        labels[i]
    return


$(document).on "page:change", ->
  $('.graph-leaderboard').each (idx, el) ->
    new LeaderboardGraph(el).fetch()
    
