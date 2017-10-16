class OrganisationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.all.merge(user.organisations)
      end
    end
  end

  def index?
    super
  end

  def show?
    super || is_public? || (is_member? && record.enabled?)
  end

  def update?
    super || is_admin?
  end

  private

  def is_public?
    record.kind_of?(Organisation) && record.public?
  end

  def is_member?
    record.kind_of?(Organisation) && !!user.role_at?(record)
  end

  def is_admin?
    record.kind_of?(Organisation) && user.role_at?(record) == 'admin'
  end
end
