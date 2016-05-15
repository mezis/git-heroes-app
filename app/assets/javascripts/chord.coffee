# original chord graph code from
# http://bl.ocks.org/AndrewRP/raw/7468330/
doMagic = ->
  el = $('#chord-graph')
  elInfo = $('#chord-info')

  # delete old contents if any
  el.empty()
  
  width = 720
  height = 720
  outerRadius = Math.min(width, height) / 2
  innerRadius = outerRadius - 30
  arc = d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius)
  layout = d3.layout.chord().padding(.04).sortSubgroups(d3.descending).sortChords(d3.ascending)
  path = d3.svg.chord().radius(innerRadius)
  svg = d3.select('#chord-graph').
    append('svg').
      attr('viewBox', "0 0 #{width} #{height}").
    append('g').
      attr('id', 'circle').
      attr('transform', "translate(#{width/2},#{height/2})")
  svg.append('circle').attr 'r', outerRadius

  # Load data, then compute the chord layout.
  d3.csv el.data('series-url'), (series) ->
    d3.json el.data('matrix-url'), (matrix) ->

      layout.matrix matrix
      # Add a group per series
      group = svg.selectAll('.group').data(layout.groups).enter().append('g').attr('class', 'group')

      # Add a mouseover title.
      group.on 'mouseover', (d,i) ->
        elInfo.text "#{series[i].name}: #{d.value} comment(s)"
        chord.classed 'chord--faded', (p) ->
          p.source.index != i and p.target.index != i
        return
      group.on 'mouseout', ->
        elInfo.text ''
        chord.classed 'chord--faded', false
        return

      # Add the group arc.
      groupPath = group.append('path').attr('id', (d, i) ->
        'group' + i
      ).attr('d', arc).style('fill', (d, i) ->
        series[i].color
      )

      # Add a text label.
      groupText = group.append('text').attr('x', 6).attr('dy', 20)
      groupText.append('textPath').attr('xlink:href', (d, i) ->
        "#group#{i}"
      ).text (d, i) ->
        series[i].name

      # Remove the labels that don't fit. :(
      groupText.filter((d, i) ->
        groupPath[0][i].getTotalLength() / 2 - 30 < @getComputedTextLength()
      ).remove()

      # Add the chords.
      chord = svg.selectAll('.chord').data(layout.chords).enter().append('path').attr('class', 'chord').style('fill', (d) ->
        series[d.source.index].color
      ).attr('d', path)

      # Add an elaborate mouseover title for each chord.
      chord.on 'mouseover', (d) ->
        elInfo.text(
          sprintf "%(name1)s %(value12)d ⟷  %(name2)s %(value21)s",
            name1: series[d.source.index].name
            name2: series[d.target.index].name,
            value12: d.source.value,
            value21: d.target.value
        )
        chord.classed 'chord--faded', (p) ->
          p.source.index != d.source.index &&
          p.target.index != d.source.index
        return
      chord.on 'mouseout', ->
        elInfo.text ''
        chord.classed 'chord--faded', false
        return
      return
    return

$(document).on "page:change", ->
  if $('#chord-graph').length > 0
    doMagic()
