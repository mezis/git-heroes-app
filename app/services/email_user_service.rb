class EmailUserService
  include WithZoneConcern

  def initialize(org_user)
    @org_user = org_user
  end

  def can_email?
    with_time_zone(settings.tz) do
      return unless now.in_working_hours?
      return unless user.email.present?
      return unless settings.snooze_until.nil? || settings.snooze_until < now
      return if email_type.nil?
      return unless last_at.nil? || last_at.to_date < Date.current
      return unless data_present?
    end
    true
  end

  def deliver
    return unless can_email?
    with_time_zone(settings.tz) do
      settings.update_attributes!("#{email_type}_email_at": now)
      UserMailer.public_send(
        email_type,
        organisation: org,
        user:         user,
      ).deliver_now
    end
  end

  private

  def email_type
    @email_type ||=
      if now.monday?
        if settings.weekly_email_enabled?
          :weekly
        elsif settings.daily_email_enabled?
          :daily
        else
          nil
        end
      elsif now.working_day?
        if settings.daily_email_enabled?
          :daily
        else
          nil
        end
      end
  end

  def last_at
    return unless email_type.present?
    settings.read_attribute("#{email_type}_email_at")&.in_time_zone(settings.tz)
  end

  def data_present?
    case email_type
    when :daily
      # always true, until we do daily scoring + use the scores in emails
      # org.scored?
      # don't send email if inactive for several days
      stats.activity?
    when :weekly
      org.rewarded?
    else false
    end
  end

  def now
    @now ||= Time.current.in_time_zone(settings.tz)
  end

  def user
    @org_user.user
  end

  def settings
    user.settings
  end

  def org
    @org_user.organisation
  end

  def stats
    PersonalStatsService.new(organisation: org, user: user, range: 2.working.days.ago .. Time.current)
  end
end
