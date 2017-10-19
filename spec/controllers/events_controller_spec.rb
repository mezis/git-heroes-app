require 'rails_helper'

describe EventsController, type: :controller do
  describe 'POST create' do
    let(:data) { load_sample('event_pull-request-opened', as: :json) }
    let(:perform) {
      request.headers['X-GitHub-Event'] = 'pull_request'
      post :create, data.to_json
    }

    it 'responds 201' do
      expect(perform.status).to eq(201)
    end

    it 'enqueues IngestEventJob' do
      expect { perform }.to have_enqueued_job(IngestEventJob).with(
        event: 'pull_request',
        data:  data,
      )
    end
  end
end
