require 'rails_helper'

describe HomepageController, type: :controller do
  render_views

  describe "GET #show" do
    let(:perform) { get :show }

    shared_examples 'status' do
      it 'responds 200' do
        perform
        expect(response.status).to eq(200)
      end
    end

    context 'when logged out' do
      include_examples 'status'
    end

    context 'when logged in' do
      let(:user) { create(:user, :logged_in) }
      let(:o1) { create(:organisation) }
      let(:o2) { create(:organisation) }

      before do
        user.organisations = [o1,o2]
        request.session[:token] = user.token
      end

      include_examples 'status'

      it 'assigns @organisations' do
        perform
        expect(assigns(:organisations)).to match([o1, o2])
      end
    end
  end
end
