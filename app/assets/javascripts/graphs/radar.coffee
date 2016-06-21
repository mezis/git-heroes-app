class GraphRadar
  constructor: (@el) ->
    $(window).resize =>
      this.render()
  
  fetch: ->
    d3.csv $(@el).data('url'), this.parser, (error, data) =>
      @data = data
      @_dimensionNames = null
      @_angles = null
      this.render()

  parser: (d) ->
    d3.keys(d).
      filter((dim) -> dim != 'name').
      forEach((dim) -> d[dim] = +d[dim])
    d

  # set variables from the element itself
  initialSetup: ->
    @scaling = $(@el).data('scaling') || 'default'
    @aoffset = $(@el).data('offset')  || 0
    @roffset = $(@el).data('roffset') || 20
    @padding = $(@el).data('padding') || 12
    this

  # set variables required for render
  renderSetup:  ->
    @width  = $(@el).width()
    @height = @width
    @radius = (@width - 2*@padding)/2

    @names = d3.keys(@data[0]).filter (dim) ->
      dim != 'name'

    @angles = {}
    @degrees = {}
    @names.forEach (dim, i) =>
      @degrees[dim] = i * 360.0 / @names.length + @aoffset
      @angles[dim]  = @degrees[dim] * 2*Math.PI / 360
    this


  # build a scale (assumes setup)
  makeScale: (max) ->
    d3.scale.
      linear().
      domain([0, max]).
      range([@roffset, @radius]).
      nice()


  # return the (memoized) scale for a given series and dimension
  getScale: (series, dim) ->
    switch @scaling
      # one scale per dimension
      when 'dimension'
        unless @scales?
          @scales = {}
          @names.forEach (dim) =>
            max = d3.max @data, (d) ->
              d[dim]
            @scales[dim] = this.makeScale(max)
        @scales[dim]
      # one scale per series
      when 'series'
        unless @scales?
          @scales = {}
          @data.forEach (d, i) =>
            max = d3.max(@names.map (dim) -> d[dim])
            @scales[i] = d3.scale.
              linear().
              domain([0, max]).
              range([@roffset, @radius]).
              nice()
        @scales[series]
      # default - single, global scale
      else
        unless @scales?
          max = d3.max(
            @names.map (dim) =>
              d3.max @data, (d) -> d[dim]
            )
          @scales = this.makeScale(max)
        @scales


  # polar to cartesian
  transform: (series, dim, value) ->
    angle = @angles[dim]
    ux = Math.cos(angle)
    uy = Math.sin(angle)
    [
      this.getScale(series, dim)(value) * ux,
      this.getScale(series, dim)(value) * uy
    ]

  render: ->
    return unless @data?
    $(@el).empty()

    this.initialSetup()
    this.renderSetup()

    # setup chart root
    svg = d3.select(@el).
      append('svg').
        attr('viewBox', "0 0 #{@width} #{@height}").
      append('g').
        attr('id', 'center').
        attr('transform', "translate(#{@padding + @radius},#{@padding + @radius})")
    axes = svg.append('g').
      attr('class', 'chart-radar-axes')
    series = svg.append('g').
      attr('class', 'chart-radar-series')

    # draw polygons
    @data.forEach (d, i) =>
      points = @names.map( (dim) =>
        this.transform(i, dim, d[dim])
      )
      line = d3.svg.line().
        interpolate('cardinal')
      series.append('path').
        attr('d', line(points) + 'Z')

    # draw axes
    @names.forEach (dim) =>
      # draw axis lines
      x = (@radius + @padding/2) * Math.cos(@angles[dim])
      y = (@radius + @padding/2) * Math.sin(@angles[dim])
      axes.append('g').
        attr('transform', "rotate(#{@degrees[dim]})").
        append('line').
          attr('x1', @roffset).attr('y1', 0).
          attr('x2', @radius).attr('y2', 0)

      # add dimension labels
      labels = axes.append('g').
        attr('class', 'chart-text-protected').
        attr('transform', "translate(#{x},#{y})")
      [1,2].forEach ->
        labels.append('text').
          attr('class', 'chart-radar-dim-name').
          text(dim)

    # draw circles (when there's a single scale)
    if @scaling == 'default'
      @scales.ticks().forEach (v) =>
        axes.append('circle').
          attr('r', @scales(v))

    $(@el).trigger('svg:load')
    return

    
$(document).on "turbolinks:load", ->
  $('.graph-radar').each (idx, el) ->
    new GraphRadar(el).fetch()
