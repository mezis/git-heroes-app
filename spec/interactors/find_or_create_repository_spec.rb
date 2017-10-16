require 'rails_helper'

describe FindOrCreateRepository do
  let(:data) { load_sample('event_repository') }
  let(:context) {{
    data: data['repository']
  }}
  let(:result) { described_class.call(context) }

  context 'when the repository does not exist' do
    it { expect { result }.to change { Repository.count }.by(1) }
    it { expect(result.record).to be_enabled }
    it { expect(result.created).to be_truthy }
    it { expect(result.updated).to be_falsy }
  end

  context 'when the repository already exists' do
    before { create(:repository, github_id: 27496774, owner: create(:organisation)) }
    it { expect { result }.not_to change { Repository.count } }
    it { expect(result.record).not_to be_enabled }  
    it { expect(result.created).to be_falsy }
    it { expect(result.updated).to be_truthy }
  end
end
