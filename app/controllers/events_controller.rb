class EventsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :skip_authorization

  def create
    event_type = request.headers['X-GitHub-Event']
    if event_type.blank?
      Rails.logger.warn 'Missing event type, ignoring'
    else
      IngestEventJob.perform_later(
        event: event_type,
        data:  JSON.parse(request.body.read),
      )
    end

    render nothing: true, status: 201
  end
end
