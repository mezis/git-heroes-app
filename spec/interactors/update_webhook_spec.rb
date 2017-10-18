require 'rails_helper'

describe UpdateWebhook do
  let(:data_list) { load_sample('org-hook-index') }
  let(:data_create) { load_sample('org-hook-create') }
  let(:data_edit) { load_sample('org-hook-edit') }

  let(:u) { create(:user, :logged_in) }
  let!(:ou) { create(:organisation_user, user: u, role: 'admin') }

  def perform
    described_class.call(organisation: ou.organisation)
  end

    before do
      allow_any_instance_of(GithubClient).to receive(:org_hooks).and_return(data_list)
      allow_any_instance_of(GithubClient).to receive(:edit_org_hook).and_return(data_edit)
      allow_any_instance_of(GithubClient).to receive(:create_org_hook).and_return(data_create)
    end

  context 'when the webhook does not exist' do
    before { data_list.clear }
    it { expect_any_instance_of(GithubClient).to receive(:create_org_hook) ; perform } 
    it { expect_any_instance_of(GithubClient).not_to receive(:edit_org_hook) ; perform } 
    it { expect(perform.updated).to be_falsy }
    it { expect(perform.created).to be_truthy }
  end

  context 'when the webhook is correct' do
    before do
      data_list[0].deep_merge!(described_class::DESIRED_DATA)
    end

    it { expect_any_instance_of(GithubClient).not_to receive(:create_org_hook) ; perform } 
    it { expect_any_instance_of(GithubClient).not_to receive(:edit_org_hook) ; perform } 
    it { expect(perform.updated).to be_falsy }
    it { expect(perform.created).to be_falsy }
  end

  context 'when the webhook is present but broken' do
    it { expect_any_instance_of(GithubClient).not_to receive(:create_org_hook) ; perform } 
    it { expect_any_instance_of(GithubClient).to receive(:edit_org_hook) ; perform } 
    it { expect(perform.updated).to be_truthy }
    it { expect(perform.created).to be_falsy }
  end
end
