$(document).on "page:change", ->
  $('[data-toggle="tooltip"]').tooltip
    delay:
      show: 250
      hide: 100
