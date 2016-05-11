class EventsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :skip_authorization

  def create
    IngestEventJob.perform_later(
      event: request.headers['X-GitHub-Event'],
      data:  JSON.parse(request.body.read),
    )
    render nothing: true, status: 201
  end
end
