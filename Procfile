web: puma
worker: QUEUES=* rake environment resque:work
scheduler: VERBOSE=1 rake environment resque:scheduler
