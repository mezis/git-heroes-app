require 'rails_helper'

describe UsersController, type: :controller do
  render_views

  shared_examples 'success' do
    it 'returns http success' do
      perform
      expect(response).to have_http_status(:success)
    end
  end

  let(:ou) { create(:organisation_user) }
  let(:user) { ou.user }
  let(:org) { ou.organisation }

  before { log_in! user }

  describe 'GET #index' do
    let(:params) {{ organisation_id: org.name }}
    let(:perform) { get :index, params }

    include_examples 'success'
  end

  describe 'GET #show' do
    let(:params) {{ id: user.login }}
    let(:perform) { get :show, params }

    context 'global user' do
      include_examples 'success'
    end

    context 'org user' do
      let(:params) { super().merge(organisation_id: org.name) }
      include_examples 'success'
    end
  end

  describe 'PATCH #update' do
    let(:params) {{ id: user.login, user: { email: 'john@doe.com' } }}
    let(:perform) { xhr :patch, :update, params }

    include_examples 'success'

    it 'updates user' do
      expect { perform }.to change { user.reload.email }
    end
  end

end
