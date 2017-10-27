require 'rails_helper'

describe TeamMetricsController, type: :controller do
  render_views

  describe "GET #show" do
    let!(:org) { create(:organisation, enabled: true) }
    let!(:user) { create(:user, :logged_in) }
    let!(:team) { create(:team, organisation: org, enabled: true) }

    before { log_in! user }

    let(:perform) { get :show, { format: format }.merge(params) }

    shared_examples 'success' do
      describe 'member list' do
        let(:format) { 'csv' }

        it 'returns http success' do
          perform
          expect(response).to have_http_status(:success)
        end

        it 'returns a list of members' do
          perform
          expect(csv_data.headers).to eq %w[name color url]
        end
      end

      describe 'collaboration matrix' do
        let(:format) { 'json' }

        it 'returns http success' do
          perform
          expect(response).to have_http_status(:success)
        end

        it 'returns a square matrix' do
          perform
          expect(json_data).to be_an(Array)
          json_data.each do |row|
            expect(row.length).to eq(json_data.length)
          end
        end
      end
    end

    describe 'organisation metrics' do
      let(:params) {{ organisation_id: org.name }}
      it_behaves_like 'success'
    end

    describe 'team metrics' do
      let(:params) {{ organisation_id: org.name }}
      it_behaves_like 'success'
    end
  end

end
