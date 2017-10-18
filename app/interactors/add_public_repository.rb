# Add a public repository
class AddPublicRepository
  include GithubInteractor

  def call
    data = client.repo(context.name)
    builder = FindOrCreateRepository.call(data: data)
    context.record = builder.record
    context.created = builder.created
    context.updated = builder.updated
  end

  private

  def user
    pick_user(User)
  end
end
