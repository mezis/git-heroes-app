class RepositoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.plays?(:admin)
        scope.all
      else
        scope.merge(user.member_repositories)
      end
    end
  end
end
