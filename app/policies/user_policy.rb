class UserPolicy < ApplicationPolicy
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
    super || (user && (user.organisations & record.organisations).any?)
  end

  def update?
    super || (user == record)
  end

  def compare?
    user.admin? ||
      record.teams.any? { |t| user.role_at?(t) == 'maintainer' } ||
      record.organisations.any? { |o| user.role_at?(o) == 'admin' }
  end
end
