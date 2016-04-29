class UpdateUserOrganisations
  include Interactor

  def call
    context.fail! 'missing user' unless context.user.present?

    client = GithubClient.new(user)

    orgs = client.organizations.map do |hash|
      Organisation.find_or_create_by!(github_id: hash.id) do |o|
        o.name = hash.login
      end
    end
    context.user.organisations = orgs
  end
end
