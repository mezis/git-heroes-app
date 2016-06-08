require 'rails_helper'

RSpec.describe UserSettingsController, type: :controller do

  describe "GET #update" do
    xit "returns http success" do
      get :update
      expect(response).to have_http_status(:success)
    end
  end

end
