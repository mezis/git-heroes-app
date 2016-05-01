class UpdateUserRepositoriesJob < BaseJob

  def perform(options = {})
    user = User.find_by_id(options[:actor_id])
    result = UpdateUserRepositories.call(user: user)
  end
end
