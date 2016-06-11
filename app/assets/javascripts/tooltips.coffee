$(document).on "turbolinks:load", ->
  $(document).trigger("tooltip:update")

$(document).on "tooltip:update", (e) ->
  $(e.target).find('[data-toggle="tooltip"]').tooltip
    html:   true
    delay:
      show: 0
      hide: 100
