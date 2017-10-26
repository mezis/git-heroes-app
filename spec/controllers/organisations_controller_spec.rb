require 'rails_helper'

describe OrganisationsController, type: :controller do
  render_views

  let(:user) { create(:user, :logged_in) }
  let(:org) { create(:organisation, enabled: true) }
  let!(:ou) { create(:organisation_user, user: user, organisation: org) }

  before { log_in! user }

  describe 'GET #index' do
    let(:perform) { get :index }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'assigns @organisations' do
      perform
      expect(assigns[:organisations]).not_to be_empty
    end
  end

  describe 'GET #show' do
    let(:perform) { get :show, id: org.name }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'assigns @organisation' do
      perform
      expect(assigns[:organisation]).to be_present
    end
  end

  describe 'PATCH #update' do
    let(:perform) { patch :update, id: org.name, enabled: 'false' }

    before { ou.update_attributes!(role: 'admin') }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'updates the org' do
      expect { perform }.to change { org.reload.enabled }.to false
    end
  end

end
