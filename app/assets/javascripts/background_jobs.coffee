class BackgroundJobsUpdater
  constructor: ->
    @el = '#background-jobs'
    @timeout = null

  onReady: =>
    this.onTick()
    
    # @interval ||= window.setInterval this.onTick.bind(this), 5000

  onTick: =>
    clearTimeout(@timeout) if @timeout
    @timeout = null

    url = $(@el).parent().data('refresh-url')
    delay = $(@el).data('refresh-delay')
    console.log "refreshing from #{url}"
    $.ajax(
      url:    url
      global: false
    ).success(this.onResponse)

  onResponse: (data, status, xhr) =>
    $(@el).trigger('ajax:success', [data, status, xhr])

    delay = $(@el).data('refresh-delay')

    console.log "scheduling refresh after #{delay}"
    clearTimeout(@timeout) if @timeout
    @timeout = setTimeout(this.onTick.bind(this), delay)
    true

  element: ->

$(document).ready (new BackgroundJobsUpdater).onReady


