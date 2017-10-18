require 'rails_helper'

RSpec.describe UpdateUserRepositoriesJob, type: :job do
  let(:user) { create(:user) }
  let(:repo1) { create(:repository) }
  let(:repo2) { create(:repository) }

  before do
    allow(UpdateUserRepositories).to receive(:call).
      with(user: user).
      and_return(Hashie::Mash.new(
        created: [repo1],
        updated: [repo2],
      ))
  end

  let(:perform) { described_class.new.perform(user: user) }

  it 'enqueues import jobs' do
    expect { perform }.to have_enqueued_job(ImportRepositoryPullRequestsJob)
  end

  it 'enqueued update jobs' do
    expect { perform }.to have_enqueued_job(UpdateRepositoryPullRequestsJob)
  end
end
