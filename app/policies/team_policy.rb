class TeamPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def show?
    super || is_member? || OrganisationPolicy.new(user, record.organisation).show?
  end

  def update?
    super || is_admin? || OrganisationPolicy.new(user, record.organisation).update?
  end

  private
  
  def is_member?
    !!user.role_at?(record)
  end
  
  def is_admin?
    user.role_at?(record) == 'maintainer'
  end
end
