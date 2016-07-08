class OrganisationUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    # can calways list users, but scope limited to member organisations
    # in controllers
    true
  end

  def show?
    super ||
      (user == record.user) ||
      (user && (user.organisations & record.user.organisations).any?)
  end

  def update?
    super || (user == record.user)
  end
end

