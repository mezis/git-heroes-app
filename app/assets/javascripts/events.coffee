window.Heroes =
  dispatch: (eventName, {target, cancelable, data} = {}) ->
    event = document.createEvent("Events")
    event.initEvent(eventName, true, cancelable is true)
    event.data = data ? {}
    (target ? document).dispatchEvent(event)
    event
