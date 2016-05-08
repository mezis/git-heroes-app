module MetricsHelper
  DEFAULT_LINE_CHART_OPTIONS = {
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
        1 => {
          lineWidth: 1,
        },
      },
      series: {
        0 => {
          visibleInLegend: true,
        },
        1 => {
          visibleInLegend: true,
        },
      },
      legend: {
        position: 'in',
      },
    }
  }

  DEFAULT_COLUMN_CHART_OPTIONS = {
    library: {
      theme:            'maximized',
      bar: {
        # groupWidth:     3,
      },
    }
  }

  DEFAULT_BAR_CHART_OPTIONS = {
    library: {
      theme:            'maximized',
      bar: {
        # groupWidth:     3,
      },
    }
  }

  def gh_line_chart(location, options = {})
    line_chart url_for(location), DEFAULT_LINE_CHART_OPTIONS.deep_merge(options)
  end

  def gh_column_chart(location, options = {})
    column_chart url_for(location), DEFAULT_COLUMN_CHART_OPTIONS.deep_merge(options)
  end

  def gh_bar_chart(location, options = {})
    bar_chart url_for(location), DEFAULT_BAR_CHART_OPTIONS.deep_merge(options)
  end
end
