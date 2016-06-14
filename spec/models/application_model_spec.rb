require 'rails_helper'

describe ApplicationModel do
  let(:org) { create :organisation }

  describe '.find_or_create_by!' do
    it 'reattempts' do
      expect {
        User.find_or_create_by!(login: 'foo') do |r|
          r.github_id  = 1234

          # sneakily create a record in the meantime (using a different
          # connection
          User.create!(login: 'foo', github_id: 1234)
        end
      }.to change { User.count }.by(1)
    end
  end
end
