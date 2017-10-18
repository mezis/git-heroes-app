require 'rails_helper'

describe RepositoriesDecorator do
  subject { described_class.new(repos) }

  describe '#contributors' do
    let(:repos) { [repo1, repo2] }
    let(:repo1) { create(:repository) }
    let(:repo2) { create(:repository) }

    let(:user11) { create(:user) }
    let(:user12) { create(:user) }
    let(:user21) { create(:user) }
    let(:user22) { create(:user) }

    let!(:pr11) { create(:pull_request, repository: repo1, created_by: user11) }
    let!(:pr12) { create(:pull_request, repository: repo1, created_by: user12) }
    let!(:pr21) { create(:pull_request, repository: repo2, created_by: user21) }
    let!(:pr22) { create(:pull_request, repository: repo2, created_by: user22) }

    before do
      PullRequest.update_all(merged_at: 1.hour.ago)
    end

    it 'lists the pr authors' do
      expect(subject.first.contributors).to match([user11, user12])
      expect(subject.last.contributors).to match([user21, user22])
    end
  end
end
