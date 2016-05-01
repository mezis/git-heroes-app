web: puma
worker: VERBOSE=1 QUEUES=* rake environment resque:work
scheduler: VERBOSE=1 rake environment resque:scheduler
