require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "daily" do
    let(:mail) { UserMailer.daily }

    xit "renders the headers" do
      expect(mail.subject).to eq("Daily")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    xit "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "weekly" do
    let(:mail) { UserMailer.weekly }

    xit "renders the headers" do
      expect(mail.subject).to eq("Weekly")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    xit "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
