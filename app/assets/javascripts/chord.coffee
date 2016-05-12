# original chord graph code from
# http://bl.ocks.org/AndrewRP/raw/7468330/
doMagic = ->
  el = $('#chord-graph')

  # delete old contents if any
  el.empty()
  
  # get config
  citiesUrl = el.data('series-url')
  matrixUrl = el.data('matrix-url')

  width = 720
  height = 720
  outerRadius = Math.min(width, height) / 2 - 10
  innerRadius = outerRadius - 24
  formatPercent = d3.format('.1%')
  arc = d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius)
  layout = d3.layout.chord().padding(.04).sortSubgroups(d3.descending).sortChords(d3.ascending)
  path = d3.svg.chord().radius(innerRadius)
  svg = d3.select('#chord-graph').
    append('svg').
      attr('viewBox', "0 0 #{width} #{height}").
    append('g').
      attr('id', 'circle').
      attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')
  svg.append('circle').attr 'r', outerRadius
  d3.csv citiesUrl, (cities) ->
    d3.json matrixUrl, (matrix) ->
      # Compute the chord layout.

      mouseover = (d, i) ->
        chord.classed 'fade', (p) ->
          p.source.index != i and p.target.index != i
        return

      layout.matrix matrix
      # Add a group per neighborhood.
      group = svg.selectAll('.group').data(layout.groups).enter().append('g').attr('class', 'group').on('mouseover', mouseover)
      # Add a mouseover title.
      # group.append("title").text(function(d, i) {
      # return cities[i].name + ": " + formatPercent(d.value) + " of origins";
      # });
      # Add the group arc.
      groupPath = group.append('path').attr('id', (d, i) ->
        'group' + i
      ).attr('d', arc).style('fill', (d, i) ->
        cities[i].color
      )
      # Add a text label.
      groupText = group.append('text').attr('x', 6).attr('dy', 15)
      groupText.append('textPath').attr('xlink:href', (d, i) ->
        '#group' + i
      ).text (d, i) ->
        cities[i].name
      # Remove the labels that don't fit. :(
      groupText.filter((d, i) ->
        groupPath[0][i].getTotalLength() / 2 - 16 < @getComputedTextLength()
      ).remove()
      # Add the chords.
      chord = svg.selectAll('.chord').data(layout.chords).enter().append('path').attr('class', 'chord').style('fill', (d) ->
        cities[d.source.index].color
      ).attr('d', path)
      # Add an elaborate mouseover title for each chord.
      chord.append('title').text (d) ->
        cities[d.source.index].name + ' → ' + cities[d.target.index].name + ': ' + formatPercent(d.source.value) + '\n' + cities[d.target.index].name + ' → ' + cities[d.source.index].name + ': ' + formatPercent(d.target.value)
      return
    return

$(document).on "page:change", ->
  if $('#chord-graph').length > 0
    doMagic()
