class UpdateUserOrganisations
  include GithubInteractor

  delegate :user, :created, :updated, to: :context

  def call
    context.created = []
    context.update = []
    user.organisations = client.organizations.map { |hash|
      result = FindOrCreateOrganisation.call(data: hash)
      context.created << result.record if result.created
      context.updated << result.record if result.updated
      result.record
    }
  end
end
