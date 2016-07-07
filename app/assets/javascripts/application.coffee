# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require d3
#= require sprintf
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require tether
#= require bootstrap-sprockets
#= require nprogress
#= require nprogress-turbolinks
#= require nprogress-ajax
#= require_tree .
#= require_self


$(document).on "turbolinks:load", ->
  $('[data-smooth-scroll] a').on('click', (e) ->
    target = e.target.hash
    $('html, body').animate({
      scrollTop: $(target).offset().top
    }, 300)
    false
  )

$(document).on "turbolinks:load ajax:replaced", (e) ->
  $(e.target).find('select[data-autosubmit]').on('change', (e) ->
    $(e.target).closest('form').submit()
    false
  )
