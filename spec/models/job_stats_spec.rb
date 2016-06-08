require 'rails_helper'

describe JobStats do
  let(:actor) { create :user }
  
  subject { described_class.new(
    id:        'dead-beef',
    actors:    actor,
    job_class: 'FailJob',
    args_hash: '1234abcd',
  )}

  describe 'CRUD' do
    let(:reloaded) { subject.save! ; described_class.find(subject.id) }

    it 'saves' do
      expect { subject.save! }.not_to raise_error
      expect(subject).to be_persisted
    end

    it 'saves/loads' do
      subject.save!
      expect {
        described_class.find('dead-beef')
      }.not_to raise_error
    end

    it 'reloads correct data' do
      expect(reloaded.actors).to eq([actor])
    end
  end

  describe '#duplicate?' do
    context 'when job exists with same class/args' do
      before do
        described_class.create!(
          id:        '1337-f00d',
          job_class: 'FailJob',
          args_hash: '1234abcd',
        )
      end

      it { is_expected.to be_duplicate }
    end

    context 'when no job exists' do
      it { is_expected.not_to be_duplicate }
    end
  end

  describe '.find_or_initialize_by' do
    let(:job) { FailJob.new(:foo, actors: actor) }
    subject { described_class.find_or_initialize_by(job: job) }

    context 'when not existing' do
      it { is_expected.not_to be_persisted }
      it { is_expected.to be_valid }
    end

    context 'when existing' do
      before do 
        js = described_class.find_or_initialize_by(job: job)
        js.attempts = 666
        js.save!
      end

      it { is_expected.to be_persisted }
      its(:attempts) { are_expected.to eq(666) }
    end
  end

  describe '.where' do
    let(:other_actor) { create :organisation }
    let(:jobs) {[
      FailJob.new(:foo, actors: actor),
      FailJob.new(:foo, actors: [actor, other_actor]),
      FailJob.new(:bar, actors: []),
      FailJob.new(:baz, actors: [])
    ]}

    before do
      jobs.each do |j|
        described_class.find_or_initialize_by(job: j).save!
      end
    end

    def results(actor)
      described_class.where(actor: actor)
    end

    it 'lists entries by actor' do
      results = described_class.where(actor: other_actor)
      expect(results.first).not_to be_nil
      expect(results.first).to be_a_kind_of(described_class)
      expect(results.count).to eq 1
    end

    it 'locates entries with multiple actors' do
      results = described_class.where(actor: actor)
      expect(results.count).to eq 2
    end

    it 'lists entries with no actor' do
      results = described_class.where(actor: nil)
      expect(results.count).to eq 2
    end
  end
end
