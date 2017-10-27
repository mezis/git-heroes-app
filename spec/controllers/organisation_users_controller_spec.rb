require 'rails_helper'

describe OrganisationUsersController, type: :controller do
  render_views

  let(:user) { create(:user, :logged_in) }
  let(:ou) { create(:organisation_user, user: user) }
  let(:org) { ou.organisation }

  before { log_in! user }

  before { request.headers['Referer'] = 'http://example.com' }

  describe "PATCH #update" do
    let(:params) {{
      id: user.login,
      organisation_id: org.name,
      organisation_user: {
        email: 'foo@example.com'
      }
    }}

    shared_examples 'updates the org user' do
      it 'changes the org user' do
        expect { perform }.to change { ou.reload.email }.to 'foo@example.com'
      end
    end

    context 'normal request' do
      let(:perform) { patch :update, params }

      it_behaves_like 'updates the org user'

      it 'redirects' do
        perform
        expect(response).to redirect_to('http://example.com')
      end
      
      it 'flashes' do
        perform
        expect(flash[:notice]).not_to be_blank
      end
    end

    context 'XHR' do
      let(:perform) { xhr :patch, :update, params }

      it_behaves_like 'updates the org user'

      it 'succeeds' do
        perform
        expect(response).to have_http_status(200)
      end

      it 'clears the flash' do
        perform
        expect(flash).to be_empty
      end
    end
  end

end
