class OrganisationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.merge(user.organisations)
      end
    end
  end

  def index?
    true
  end

  def show?
    super || is_member?
  end

  def update?
    super || is_admin?
  end

  private

  def is_member?
    !!user.role_at?(record)
  end

  def is_admin?
    user.role_at?(record) == 'admin'
  end
end
