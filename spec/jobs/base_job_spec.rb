require 'rails_helper'

describe BaseJob do
  it 'does not enqueue duplicates' do
    3.times { Debug::FailJob.perform_later('foo') }
    Debug::FailJob.perform_later('bar')

    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.length).to eq(2)
  end

  it 'ignores actors: and parent: on duplicates' do
    job = Debug::FailJob.perform_later('foo')
    Debug::FailJob.perform_later('foo', actors:[create(:user)])
    Debug::FailJob.perform_later('foo', parent: job)

    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.length).to eq(1)
  end
end
