require 'rails_helper'

describe FindOrCreateRepository do
  let(:data) { load_sample('event_repository') }
  let(:context) {{
    data: data['repository']
  }}
  let(:result) { described_class.call(context) }


  it { expect { result }.not_to raise_error }

  it { expect { result }.to change { Repository.count }.by(1) }

  it { expect(result.record).to be_enabled }
end
