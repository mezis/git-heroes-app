require 'rails_helper'

describe SessionsController, type: :controller do
  render_views

  describe 'GET #show' do
    let(:perform) { get :show }

    it 'redirects' do
      perform
      expect(response).to redirect_to('/')
    end

    it 'flashes an error' do
      perform
      expect(flash[:alert]).not_to be_empty
    end
  end


  describe 'GET #callback' do
    let(:perform) { get :callback }
    
    before { allow_any_instance_of(GithubClient).to receive(:emails).and_return(load_sample 'user-emails') }

    before do
      request.env['omniauth.auth'] = Hashie::Mash.new(
        extra: {
          raw_info: {
            id:    12345,
            login: 'johndoe',
            name:  'John Doe',
            email: 'john@doe.com',
          },
        },
        credentials: {
          token: 's3cr3t',
        }
      )
    end

    it 'creates the user' do
      expect { perform }.to change { User.count }.by(1)
    end

    it 'logs the user in' do
      perform
      u = User.find_by!(login: 'johndoe')
      expect(session[:token]).to eq(u.token)
    end

    it 'redirects' do
      perform
      expect(response).to redirect_to '/'
    end

    it 'flashes' do
      perform
      expect(flash[:notice]).not_to be_blank
    end
  end


  describe 'GET #intermission' do
    def perform ; get :intermission ; end

    context 'on first run' do
      it 'succeeds' do
        perform
        expect(response).to have_http_status(:success)
      end

      it 'changes the cookies' do
        expect { perform }.to change { cookies['_ghdata'] }
      end
    end

    context 'on second run' do
      it 'redirects' do
        perform
        perform
        expect(response).to redirect_to('/auth/github')
      end
    end
  end


  describe 'GET #update' do
    let(:perform) { get :update, act_as: other_user.id }

    let(:admin) { create(:user, admin: true) }
    let(:other_user) { create(:user) }

    before { log_in! admin }
    before { request.headers['Referer'] = '/foo' }

    it 'redirects' do
      perform
      expect(response).to redirect_to('/foo')
    end

    it 'sets the session acts_as' do
      perform
      expect(session[:act_as]).to eq(other_user.id.to_s)
    end
  end


  describe 'GET #destroy' do
    let(:perform) { get :destroy }
    let(:user) { create(:user) }

    before { log_in! user }
    
    it 'redirects' do
      perform
      expect(response).to redirect_to('/')
    end

    it 'clears the session' do
      expect { perform }.to change { session[:token] }.to nil
    end
  end
end
