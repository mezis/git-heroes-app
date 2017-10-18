require 'rails_helper'

describe UpdateUserRepositories do
  let(:data_l) { load_sample('repos-index') }
  let(:data_r) { load_sample('repository-long') }
  # let(:repo) { FindOrCreateRepository.call(data: data.base.repo).record }
  let(:user) { create(:user, :logged_in) }
  before do
    allow_any_instance_of(GithubClient).to receive(:repositories).and_return(data_l)
    allow_any_instance_of(GithubClient).to receive(:repo).with('octocat/Hello-World').and_return(data_r)
  end

  def perform
    described_class.call(user: user)
  end

  it { expect { perform }.to change { Repository.count }.by(1) }
  it { expect { perform }.to change { user.member_repositories.count } }
  it { expect(perform.created.length).to eq(1) }
  it { expect(perform.updated.length).to eq(0) }

  context 'when user is not logged in' do
    let(:user) { create(:user) }
    let(:repo) { create(:repository) }
    
    before do
      create(:user_repository, user: user, repository: repo)
    end

    it 'removes known repo memberships' do
      expect { perform }.to change { user.member_repositories.count }.to(0)
    end
  end
end

