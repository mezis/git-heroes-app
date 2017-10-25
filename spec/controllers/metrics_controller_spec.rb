require 'rails_helper'

RSpec.describe MetricsController, type: :controller do
  # params:
  # id - metric name
  # organisation_id
  # team_id (optional)
  # user_id (optional)

  let!(:org) { create(:organisation, enabled: true) }
  let!(:user) { create(:user, :logged_in) }
  let!(:team) { create(:team, organisation: org, enabled: true) }
  let!(:repo) { create(:repository, owner: org, enabled: true) }
  let(:monday) { Date.today.beginning_of_week }
  let(:friday) { monday.beginning_of_day - 2.5.days }

  def csv_data
    CSV.parse(response.body, headers: true)
  end

  def json_data
    JSON.parse(response.body)
  end

  def setup_data
    create(:organisation_user_score,
           user:          user,
           organisation:  org,
           date:          monday,
           points:        42,
          )

    create(:pull_request,
           created_by:    user,
           repository:    repo,
           merged_at:     friday,
           created_at:    friday,
          )
    create(:comment,
           user:          user,
           pull_request:  PullRequest.last,
           created_at:    friday,
          )
  end

  before do
    log_in! user

    user.organisations = [org]
    user.teams = [team]
  end

  describe "GET #show" do
    let(:format) { 'csv' }
    let(:options) {{}}
    let(:perform) {
      get :show, {
        format: format, organisation_id: org.name, id: metric_name
      }.merge(options)
    }

    shared_examples 'a successful endpoint' do |options|
      let(:metric_name) { options[:metric] }

      %w[csv json].each do |format|
        describe "with format #{format}" do
          let(:format) { format }

          it "responds 200 for format #{format}" do
            perform
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    shared_examples 'a metric endpoint' do |options|
      context 'without data' do
        options[:metrics].each do |m|
          it_behaves_like 'a successful endpoint', metric: m
        end
      end

      context 'with data' do
        before { setup_data }

        options[:metrics].each do |m|
          it_behaves_like 'a successful endpoint', metric: m
        end
      end
    end

    describe 'org metrics' do
      org_metrics = %w[
        contribution_per_contributor
        contribution_per_contributor_over_time
        contributors_over_time
        contributions_over_time
        comments_over_time
        hour_of_pull_request_merged
      ]

      describe 'with team filter' do
        let(:options) {{ team_id: team.id }}
        it_behaves_like 'a metric endpoint', metrics: org_metrics
      end

      describe 'without team filter' do
        it_behaves_like 'a metric endpoint', metrics: org_metrics

        describe 'output data' do
          before { setup_data }

          describe 'contribution_per_contributor' do
            let(:metric_name) { 'contribution_per_contributor' }

            it 'returns points per user' do
              perform
              expect(csv_data.headers).to eq %w[user points url]
              expect(csv_data.first['user']).to eq(user.login)
              expect(csv_data.first['points']).to eq("42")
            end
          end

          describe 'contribution_per_contributor_over_time' do
            let(:metric_name) { 'contribution_per_contributor_over_time' }

            it 'returns points per date' do
              perform
              expect(csv_data.headers).to eq %w[date points]
              expect(csv_data.first['date']).to eq(monday.to_s)
              expect(csv_data.first['points'].to_f).to be_within(1e-3).of(42)
            end
          end

          describe 'contributors_over_time' do
            let(:metric_name) { 'contributors_over_time' }

            it 'returns points per date' do
              perform
              expect(csv_data.headers).to eq %w[date count]
              expect(csv_data.first['date']).to eq(monday.to_s)
              expect(csv_data.first['count'].to_f).to eq(1)
            end
          end

          describe 'contributions_over_time' do
            let(:metric_name) { 'contributions_over_time' }

            it 'returns points per date' do
              perform
              expect(csv_data.headers).to eq %w[date points]
              expect(csv_data.first['date']).to eq(monday.to_s)
              expect(csv_data.first['points'].to_f).to eq(42)
            end
          end

          describe 'comments_over_time' do
            let(:metric_name) { 'comments_over_time' }

            it 'returns points per week' do
              perform
              expect(csv_data.headers).to eq %w[date comments]
              expect(csv_data.first['date']).to eq(friday.beginning_of_week.to_date.to_s)
              expect(csv_data.first['comments'].to_i).to eq(1)
            end
          end

          describe 'hour_of_pull_request_merged' do
            let(:format) { 'json' }
            let(:metric_name) { 'hour_of_pull_request_merged' }
            let(:data) { perform ; json_data.first }

            it 'returns an array' do
              perform
              expect(json_data.length).to eq(1)
            end

            describe 'the response object' do
              let(:subject) { data }

              it { expect(subject['name']).to eq('Merges') }
              it { expect(subject.keys - ['name']).to match((0..23).map(&:to_s)) }
              it { expect(subject['12']).to eq(1) } # the only PR was merged last Friday at noon
            end
          end
        end # output data
      end # without team filter
    end # org metrics
  end # GET #show
end
