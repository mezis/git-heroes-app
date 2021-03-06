class UserDecorator < SimpleDelegator

  def settings
    super.tap { |s| s.save! unless s.persisted? }
  end

  def auth_token
    @auth_token ||= AuthenticationToken.create!(user: __getobj__).id
  end
end
