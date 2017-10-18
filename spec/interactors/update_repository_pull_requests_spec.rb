require 'rails_helper'

describe UpdateRepositoryPullRequests do
  let(:data) { load_sample('pull-request-index') }
  let(:repo) { FindOrCreateRepository.call(data: data.first.base.repo).record }
  before { create(:user, :logged_in) }
  before { allow_any_instance_of(GithubClient).to receive(:pull_requests).with('octocat/Hello-World', Hash).and_return(data) }

  def perform
    described_class.call(repository: repo, number: 1347)
  end

  it { expect { perform }.to change { PullRequest.count }.by(1) }
  it { expect(perform.record_ids).to include(PullRequest.last.id) }
end
