module MetricsHelper
  def gh_line_chart(location, options = {})
    line_chart url_for(location), {
      library: {
        theme:      'maximized',
        curveType:  'none',
        fontName:   'Helvetica',
        lineWidth:  3,
        pointSize:  0,
        trendlines: { 
          0 => {
            lineWidth: 1,
          },
        },
      }
    }.deep_merge(options)
  end

  def gh_column_chart(location, options = {})
    column_chart url_for(location), {
      library: {
        theme:            'maximized',
        bar: {
          groupWidth:     3,
        },
      }
    }.deep_merge(options)
  end

  def gh_bar_chart(location, options = {})
    bar_chart url_for(location), {
      library: {
        theme:            'maximized',
        bar: {
          groupWidth:     3,
        },
      }
    }.deep_merge(options)
  end
end
