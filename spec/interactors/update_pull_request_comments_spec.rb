require 'rails_helper'

describe UpdatePullRequestComments do
  let(:data) { load_sample('pull-request-comments-index') }
  let(:repo) { create(:repository, public: true) }
  let(:pr) { create(:pull_request, repository: repo, github_number: 1347) }
  before { create(:user, :logged_in) }
  before { allow_any_instance_of(GithubClient).to receive(:pull_request_comments).with(String, Fixnum, hash_including).and_return(data) }

  def perform
    described_class.call(pull_request: pr)
  end

  it { expect { perform }.to change { Comment.count }.by(1) }
  it { expect(perform.records.length).to eq(1) }
end

