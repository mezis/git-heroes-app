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

    it 'ignores actors when hashing arguments' do
      other = described_class.find_or_initialize_by(
        job: FailJob.new(:foo, actors: create(:user)))
      expect(subject.args_hash).to eq(other.args_hash)
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

  describe '.all' do
    let(:result) { described_class.all.to_a }
    let(:jobs) {[
      FailJob.new(:foo),
      FailJob.new(:bar),
      FailJob.new(:baz)
    ]}
    let(:stats) { jobs.map { |j|
      described_class.find_or_initialize_by(job: j).save!
    }}

    it 'lists all jobs' do
      stats
      expect(result.map &:id).to eq(jobs.map(&:job_id))
    end

    it 'updates when jobs complete' do
      stats.last.complete!
      expect(result.length).to eq(2)
    end
  end

  describe 'root/parent/children' do
    let(:gen1job) { FailJob.new(:foo) }
    let(:gen2job) { FailJob.new(:foo, parent: gen1job) }
    let(:gen3job) { FailJob.new(:foo, parent: gen2job) }

    def gen1 ; described_class.find(gen1job.job_id) ; end
    def gen2 ; described_class.find(gen2job.job_id) ; end
    def gen3 ; described_class.find(gen3job.job_id) ; end

    before do
      described_class.find_or_initialize_by(job: gen1job).save!
      described_class.find_or_initialize_by(job: gen2job).save!
      described_class.find_or_initialize_by(job: gen3job).save!
    end

    it 'associates parents' do
      expect(gen1.parent_id).to be_nil
      expect(gen2.parent_id).to eq(gen1.id)
      expect(gen3.parent_id).to eq(gen2.id)
    end

    it 'associates roots' do
      expect(gen1.root_id).to eq(gen1.id)
      expect(gen2.root_id).to eq(gen1.id)
      expect(gen3.root_id).to eq(gen1.id)
    end

    it 'lists descendants' do
      expect(gen1.descendants).to eq([gen2.id, gen3.id])
      expect(gen2.descendants).to eq([gen3.id])
      expect(gen3.descendants).to eq([])
    end

    describe '#complete!' do
      it 'does not destroy when no descendants' do
        gen1.complete!
        expect(gen1).not_to be_nil
      end

      it 'destroys when no descendants' do
        gen3.complete!
        expect(gen3).to be_nil
      end 

      it 'updates descendants in ancestors' do
        gen3.complete!
        expect(gen2.descendants).to eq([])
        expect(gen1.descendants).to eq([gen2.id])
      end

      it 'cleans up after itself' do
        gen1.complete!
        gen2.complete!
        gen3.complete!
        expect(gen1).to be_nil
        expect(gen2).to be_nil
        expect(gen3).to be_nil
      end
    end

    describe '#descendants_max' do
      it 'counts descendants before any job runs' do
        expect(gen1.descendants_max).to eq 2
        expect(gen2.descendants_max).to eq 1
        expect(gen3.descendants_max).to eq 0
      end

      it 'does not change when children complete' do
        gen2.complete!
        gen3.complete!
        expect(gen1.descendants_max).to eq(2)
      end
    end

    describe '#descendants_left' do
      it 'counts descendants before any job runs' do
        expect(gen1.descendants_left).to eq 2
        expect(gen2.descendants_left).to eq 1
        expect(gen3.descendants_left).to eq 0
      end

      it 'lowers when children complete' do
        gen2.complete!
        gen3.complete!
        expect(gen1.descendants_left).to eq(0)
      end
    end
  end

end
