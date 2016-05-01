class UpdateUserRepositoriesJob < BaseJob

  def perform(options = {})
    user = User.find_by_id(options[:user_id])
    result = UpdateUserRepositories.call(user: user)
  end
end
