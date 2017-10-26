require 'rails_helper'

describe TeamsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:org) { create(:organisation, enabled: true) }
  let!(:ou) { create(:organisation_user, user: user, organisation: org) }
  let!(:team) { create(:team, organisation: org, enabled: true) }

  before { log_in! user }

  describe 'GET #index' do
    let(:perform) { get :index, organisation_id: org.name }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'assigns @teams' do
      perform
      expect(assigns[:teams]).not_to be_empty
    end
  end

  describe 'GET #show' do
    let(:perform) { get :show, organisation_id: org.name, id: team.slug }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'assigns @team' do
      perform
      expect(assigns[:team]).to be_present
    end
  end

  describe 'PATCH #update' do
    let(:perform) { patch :update, organisation_id: org.name, id: team.slug, enabled: 'false' }

    before { ou.update_attributes!(role: 'admin') }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'updates the repo' do
      expect { perform }.to change { team.reload.enabled }.to false
    end
  end
end
