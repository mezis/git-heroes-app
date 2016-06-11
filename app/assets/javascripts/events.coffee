# override Turbolinks default click events for SVG links
# https://github.com/turbolinks/turbolinks/issues/110
$(document).on 'svg:load', (e) ->
  $(e.target).find('svg a').on 'click', (e) ->
    Turbolinks.visit $(e.target).attr('href')
    false
  true

# trigger a tooltip update after populating SVG
$(document).on 'svg:load', (e) ->
  $(e.target).trigger('tooltip:update')
  true
