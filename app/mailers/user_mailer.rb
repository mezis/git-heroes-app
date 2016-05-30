class UserMailer < ApplicationMailer
  include DecorationConcern
  include Roadie::Rails::Automatic

  helper :date
  helper :application

  helper do 
    def current_organisation
      @organisation
    end
  end

  default from: 'Git Heroes <hello@githeroes.io>'
  layout 'mailer'

  def daily(organisation:, user:)
    @organisation = organisation
    @user = decorate user
    @stats = PersonalStatsService.new(organisation: @organisation, user: @user)
    @pull_requests = PullRequestFinder.new(organisation: @organisation, user: @user)
    
    mail(
      to: recipient(user),
      subject: "🕘 Daily #{@organisation.name} update -🏆  Git Heroes",
    )
    end

  def weekly(organisation:, user:)
    @organisation = organisation
    @user = decorate user
    date = organisation.scores.maximum(:date)
    @stats = PersonalStatsService.new(organisation: @organisation, user: @user)
    @pull_requests = PullRequestFinder.new(organisation: @organisation, user: @user)

    @rewards = RewardsDecorator.new(
      rewards: organisation.rewards.
        includes(:user).
        where(date: date),
      user: user
    )

    mail(
      to: recipient(user),
      subject: "🏅 Weekly #{@organisation.name} update -🏆  Git Heroes",
    )
  end

  private

  def roadie_options
    super.merge keep_uninlinable_css: false
  end

  def recipient(user)
    if user.name
      "#{user.name} <#{user.email}>"
    else
      user.email
    end
  end

end
