require 'rails_helper'

describe RepositoryPullRequestCounter do
  let(:data) { load_sample('pull-request-index') }
  let(:repo) { FindOrCreateRepository.call(data: data.first.base.repo).record }
  before { create(:user, :logged_in) }
  before { allow_any_instance_of(GithubClient).to receive(:pull_requests).with('octocat/Hello-World', hash_including(direction: 'desc')).and_return(data) }

  def perform
    described_class.call(repository: repo)
  end

  it { expect(perform.number).to eq(1347) }
end

