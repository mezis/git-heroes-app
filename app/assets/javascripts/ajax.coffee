
class AjaxUpdater
  onReady: =>
    $(document).on "ajax:success", this.onSuccess

  onSuccess: (e, data, status, xhr) =>
    $(data).each (_, el) ->
      id = $(el).attr("id")
      return unless id?
      $("##{id}").replaceWith(el)
    true

$(document).ready (new AjaxUpdater).onReady
