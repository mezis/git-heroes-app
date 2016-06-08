require 'rails_helper'

RSpec.describe AuthenticationToken, type: :model do
  let(:options) {{
    user: create(:user),
  }}
  subject { described_class.new(options) }

  describe 'CRUD' do
    it { is_expected.to be_valid }
    its('id.length') { is_expected.to eq 40 }

    it 'reloads' do
      subject.save!
      reloaded = described_class.find(subject.id)
      expect(reloaded).not_to be_nil
      expect(reloaded.user).to eq(options[:user])
    end
  end

  describe 'expires_at' do
    before { subject.save! }
    
    its(:expires_at) { is_expected.to be_within(1.minute).of(1.day.from_now) }
  end
  
  # describe 'expired?' do
  #   before { subject.save! }
  #   before { Timecop.travel(24.hours.from_now + 1) }

  #   it { is_expected.to be_expired }
  # end

  describe 'decrement!' do
    before { subject.save! }
    let(:perform) { subject.decrement! }
    # let(:reloaded) { described_class.find(subject.id) }

    it 'decrements the use counter' do
      expect {
        perform
      }.to change {
        described_class.find(subject.id).uses
      }.by(-1)
    end

    context 'when 1 use is left' do
      let(:options) {{
        user: create(:user),
        uses: 1,
      }}

      it 'removes the record' do
        perform
        expect(described_class.find(subject.id)).to be_nil
      end
    end
  end
end
