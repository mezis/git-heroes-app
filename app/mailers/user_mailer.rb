class UserMailer < ApplicationMailer
  include DecorationConcern
  include Roadie::Rails::Automatic

  helper :date
  helper :application
  helper :copy

  helper do 
    def current_organisation
      @organisation
    end
  end

  default from: 'Git Heroes <hello@githeroes.io>'
  layout 'mailer'

  def daily(org_user:)
    @organisation = org_user.organisation
    @user = decorate org_user.user
    @org_user = @organisation.organisation_users.find_by(user_id: @user.id)
    @stats = PersonalStatsService.new(organisation: @organisation, user: @user)
    @pull_requests = PullRequestFinder.new(organisation: @organisation, user: @user)
    
    mail(
      to: recipient(org_user),
      subject: "🕘 Daily #{@organisation.name} update -🏆  Git Heroes",
    )
  end

  def weekly(org_user:)
    @organisation = org_user.organisation
    @user = decorate org_user.user
    @org_user = @organisation.organisation_users.find_by(user_id: @user.id)
    date = @organisation.scores.maximum(:date)
    @stats = PersonalStatsService.new(organisation: @organisation, user: @user)
    @pull_requests = PullRequestFinder.new(organisation: @organisation, user: @user)

    @rewards = RewardsDecorator.new(
      rewards: @organisation.rewards.
        includes(:user).
        where(date: date),
      user: user
    )

    mail(
      to: recipient(org_user),
      subject: "🏅 Weekly #{@organisation.name} update -🏆  Git Heroes",
    )
  end

  private

  def roadie_options
    super.combine(
      keep_uninlinable_css: false,
      url_options: {
        host:     ENV.fetch('HOSTNAME'),
        protocol: 'https',
      },
    )
  end

  def recipient(org_user)
    email = org_user.email || org_user.user.email
    if name = org_user.user.name
      "#{name} <#{email}>"
    else
      email
    end
  end

end
