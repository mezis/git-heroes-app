# Given an Omniauth hash, finds or creates Users.
class FindOrCreateUser
  include Interactor

  delegate :auth_hash, :user, to: :context

  def call
    # binding.pry
    uid = auth_hash.uid

    context.user = User.find_or_create_by!(github_id: uid) do |u|
      assign_attributes(u, auth_hash)
      context.created = true
    end

    assign_attributes(user, auth_hash)
    user.update_attributes! github_token: auth_hash.credentials.token
  end

  private

  def assign_attributes(user, hash)
    user.assign_attributes(
      login:      hash.info.nickname,
      name:       hash.info.name,
      email:      hash.info.email,
      avatar_url: hash.info.image,
    )
  end
end
