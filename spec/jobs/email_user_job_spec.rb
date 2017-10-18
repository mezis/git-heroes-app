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

    let!(:ou) { create(:organisation_user) }

    it 'schedules jobs for each organisation user with valid settings' do
      allow_any_instance_of(EmailUserService).to receive(:can_email?).and_return(true)

      expect {
        perform
      }.to have_enqueued_job(described_class).with(organisation_user: ou)
    end
  end
end
