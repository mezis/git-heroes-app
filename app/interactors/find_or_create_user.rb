# Given an Omniauth hash, finds or creates Users.
class FindOrCreateUser
  include Interactor

  def call
    # binding.pry
    uid = context.auth_hash.uid

    context.user = User.find_or_create_by!(github_id: uid) do |u|
      u.login      = context.auth_hash.info.nickname
      u.name       = context.auth_hash.info.name
      u.email      = context.auth_hash.info.email
      u.avatar_url = context.auth_hash.info.image
      context.created = true
    end

    context.user.update_attributes! github_token: context.auth_hash.credentials.token
  end
end
