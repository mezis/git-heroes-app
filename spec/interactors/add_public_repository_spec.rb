require 'rails_helper'

describe AddPublicRepository do
  let(:data) { load_sample('repository-long') }
  before { create(:user, :logged_in) }
  before { allow_any_instance_of(GithubClient).to receive(:repo).with('octocat/Hello-World').and_return(data) }

  def perform
    described_class.call(name: 'octocat/Hello-World')
  end

  it { expect { perform }.to change { Repository.count }.by(1) }
  it { expect(perform.record&.name).to eq('Hello-World') }
  it { expect(perform.created).to be_truthy }
  it { expect(perform.updated).to be_falsy }
end
