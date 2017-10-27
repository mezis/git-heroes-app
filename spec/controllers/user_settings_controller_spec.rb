require 'rails_helper'

describe UserSettingsController, type: :controller do
  render_views

  let(:us) { create(:user_settings) }
  let(:user) { us.user }

  before { log_in! user }

  describe 'PATCH #update' do
    let(:params) {{
      id:           user.login,
      snooze_until: 1.day.from_now,
    }}

    context 'XHR request' do
      let(:perform) { xhr :patch, :update, params }

      it 'returns http success' do
        perform
        expect(response).to have_http_status(:success)
      end

      it 'updates settings' do
        expect { perform }.to change { us.reload.snooze_until }
      end

      it 'clears the flash' do
        flash[:notice] = 'hello'
        expect { perform }.to change { flash[:notice] }.to nil
      end
    end
  end
end
