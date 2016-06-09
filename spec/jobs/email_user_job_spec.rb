require 'rails_helper'

describe EmailUserJob do
  let(:perform) { described_class.perform_now(options) }

  context 'with an org user' do
    let(:options) {{
      organisation_user: create(:organisation_user)
    }}

    it 'sends an email' do
      expect_any_instance_of(EmailUserService).to receive(:deliver)
      perform
    end
  end

  context 'without arguments' do
    let(:options) {{}}

    let!(:ou1) { create(:organisation_user) }
    let!(:ou2) { create(:organisation_user) }

    it 'schedules jobs for each organisation user with valid settings' do
      allow_any_instance_of(EmailUserService).to receive(:can_email?).and_return(true)

      perform

      expect(described_class).
        to have_been_enqueued.
        with deserialize_as(organisation_user: ou1)
      expect(described_class).
        to have_been_enqueued.
        with deserialize_as(organisation_user: ou2)
    end
  end
end
