class UpdateUserEmailJob < BaseJob
  def perform(options = {})
    user = options[:user]

    if user.nil?
      User.where.not(github_token: nil).find_each do |u|
        UpdateUserEmailJob.perform_later user: u
      end
      return
    end

    UpdateUserEmail.call(user: user)
  end
end
