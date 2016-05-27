class UserMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  helper :date
  helper :application

  helper do 
    def current_organisation
      @organisation
    end
  end

  default from: 'Git Heroes <hello@githeroes.io>'

  def daily(organisation:, user:)
    @organisation = organisation
    @user = user
    @stats = PersonalStatsService.new(organisation: @organisation, user: @user)
    @pull_requests = PullRequestFinder.new(organisation: @organisation, user: @user)
    
    mail \
      subject: "Your daily #{@organisation.name} update -🏆  Git Heroes",
      to:       recipient(@user)
    end

  def weekly(organisation:, user:)
    nil
  end

  private

  def recipient(user)
    if user.name
      "#{user.name} <#{user.email}>"
    else
      user.email
    end
  end

end
