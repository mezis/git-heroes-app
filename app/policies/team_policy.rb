class TeamPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.plays?(:admin)
        scope.all
      else
        scope.merge(user.teams)
      end
    end
  end
end
