class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    # FIXME: only org members should be able to do this.
    # Probably means showing org users, not users.
    true
  end
end
