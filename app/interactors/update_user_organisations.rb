class UpdateUserOrganisations
  include GithubInteractor

  delegate :user, to: :context

  def call
    user.organisations = client.organizations.map { |hash|
      result = FindOrCreateOrganisation.call(data: hash)
      context.fail! error: 'could not find/create org' unless result.success?
      result.record
    }
  end
end
