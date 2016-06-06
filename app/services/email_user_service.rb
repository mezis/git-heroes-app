class EmailUserService
  def initialize(org_user)
    @org_user = org_user
  end

  def can_email?
    return unless now.in_working_hours?
    return unless user.email.present?
    return unless settings.snooze_until.nil? || settings.snooze_until < now
    return if email_type.nil?
    return unless last_at.nil? || last_at <= 24.hours.ago
    return unless data_present?
    true
  end

  def deliver
    return unless can_email?
    settings.update_attributes!("#{email_type}_email_at": now)
    UserMailer.public_send(
      email_type,
      organisation: org,
      user:         user,
    ).deliver_now
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
    settings.read_attribute("#{email_type}_email_at")
  end

  def data_present?
    case email_type
    when :daily
      # always true, until we do daily scoring + use the scores in emails
      # org.scored?
      true
    when :weekly
      org.rewarded?
    else false
    end
  end

  def now
    @now ||= Time.current
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
end
