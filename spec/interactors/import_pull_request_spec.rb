require 'rails_helper'

describe ImportPullRequest do
  let(:data) { load_sample('pull-request-long') }
  let(:repo) { FindOrCreateRepository.call(data: data.base.repo).record }
  before { create(:user, :logged_in) }
  before { allow_any_instance_of(GithubClient).to receive(:pull_request).with('octocat/Hello-World', 1347).and_return(data) }

  def perform
    described_class.call(repository: repo, number: 1347)
  end

  it { expect { perform }.to change { PullRequest.count }.by(1) }
  it { expect(perform.record&.github_number).to eq(1347) }
  it { expect(perform.created).to be_truthy }
  it { expect(perform.updated).to be_falsy }
end
