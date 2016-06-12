class BackgroundJobsUpdater
  constructor: ->
    @el = '#background-jobs'
    @timeout = null

  onReady: =>
    this.onTick()

  onTick: =>
    clearTimeout(@timeout) if @timeout
    @timeout = null

    url = $(@el).parent().data('refresh-url')
    delay = $(@el).data('refresh-delay')
    $.ajax(
      url:    url
      global: false
    ).success(this.onResponse)

  onResponse: (data, status, xhr) =>
    $(@el).trigger('ajax:success', [data, status, xhr])

    delay = $(@el).data('refresh-delay')

    clearTimeout(@timeout) if @timeout
    @timeout = setTimeout(this.onTick.bind(this), delay)
    true

$(document).ready (new BackgroundJobsUpdater).onReady


