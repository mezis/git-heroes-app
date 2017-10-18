require 'rails_helper'

describe GithubClient do
  subject { described_class.new(user) }
  let(:user) { create(:user, github_token: token) }

  # pass a valid token if creating/updating cassettes - but do not commit it!
  let(:token) { 'ccd8e3e3254b12eb4dc0bf53f4955c5c4de5771b' }
  let(:token) { Faker::Crypto.sha1 }

  describe '#paginate' do
    let(:repo_name) { 'mezis/fuzzily' }

    around do |ex|
      VCR.use_cassette('list mezis-fuzzily pull requests', allow_unused_http_interactions: false) do
        ex.run
      end
    end

    def perform
      subject.paginate do
        subject.pull_requests(repo_name, state: 'all', per_page: 10)
      end
    end

    it { expect(perform.count).to eq(40) }
  end
end
