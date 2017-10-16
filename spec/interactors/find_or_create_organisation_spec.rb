require 'rails_helper'
require 'support/samples'

describe FindOrCreateOrganisation do
  let(:data) { load_sample('org-short') }

  def perform
    described_class.call(data: data)
  end

  context 'when the org does not exist' do
    it { expect { perform }.to change { Organisation.count }.by(1) }
    it { expect(perform.created).to be_truthy }
    it { expect(perform.updated).to be_falsy }
  end

  context 'when the org exist, but is different' do
    before { create(:organisation, github_id: 1).save! }
    it { expect { perform }.not_to change { Organisation.count } }
    it { expect(perform.created).to be_falsy }
    it { expect(perform.updated).to be_truthy }
  end

  context 'when the org exist identically' do
    before { perform }

    it { expect { perform }.not_to change { Organisation.count } }
    it { expect(perform.created).to be_falsy }
    it { expect(perform.updated).to be_falsy }
  end
end
