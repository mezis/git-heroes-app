require 'rails_helper'

describe RepositoriesController, type: :controller do
  render_views

  let(:user) { create(:user, :logged_in) }
  let(:org) { create(:organisation, enabled: true) }
  let!(:ou) { create(:organisation_user, user: user, organisation: org) }
  let!(:repo) { create(:repository, owner: org, enabled: true) }

  before { log_in! user }

  describe 'GET #index' do
    let(:perform) { get :index, organisation_id: org.name }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'assigns @repositories' do
      perform
      expect(assigns[:repositories]).not_to be_empty
    end
  end

  describe 'PATCH #update' do
    let(:perform) { patch :update, organisation_id: org.name, id: repo.name, enabled: 'false' }

    before { ou.update_attributes!(role: 'admin') }

    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end

    it 'updates the repo' do
      expect { perform }.to change { repo.reload.enabled }.to false
    end
  end
end
