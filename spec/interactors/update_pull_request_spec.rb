require 'rails_helper'

describe UpdatePullRequest do
  let(:data) { load_sample('pull-request-long') }
  let(:repo) { FindOrCreateRepository.call(data: data.base.repo).record }
  let(:pr) { FindOrCreatePullRequest.call(data: data, repository: repo).record }

  before { create(:user, :logged_in) }
  before { allow_any_instance_of(GithubClient).to receive(:pull_request).with('octocat/Hello-World', 1347).and_return(data) }
  before { pr.update_attributes!(title: 'foobar') }

  def perform
    described_class.call(pull_request: pr)
  end

  it { expect { perform }.not_to change { PullRequest.count } }
  it { expect { perform }.to change { pr.reload.title } }
  it { expect(perform.created).to be_falsy }
  it { expect(perform.updated).to be_truthy }
end

