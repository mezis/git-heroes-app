class OrganisationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.plays?(:admin)
        scope.all
      else
        scope.merge(user.organisations)
      end
    end
  end

  def index?
    show?
  end

  def show?
    user.organisations.include?(record)
  end
end
