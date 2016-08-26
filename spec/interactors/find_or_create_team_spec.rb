require 'rails_helper'

describe FindOrCreateTeam do
  let(:data) { load_sample('event_membership-added') }
  let(:org) { FindOrCreateOrganisation.call(data: data.organization).record }
  let(:context) {{
    data:         data['team'],
    organisation: org,
  }}
  let(:result) { described_class.call(context) }

  it { expect { result }.not_to raise_error }

  it { expect { result }.to change { Team.count }.by(1) }

  it { expect(result.record).to be_enabled }
end
