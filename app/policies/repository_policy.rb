class RepositoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.merge(user.member_repositories)
      end
    end
  end

  def show?
    super || is_member?
  end

  def update?
    super || is_admin?
  end

  private
  
  def is_member?
    case record.owner_type
    when 'User'
      user.user_repositories.any? { |ur| ur.repository_id == record.id }
    else
      user.organisation_users.any? { |ou| ou.organisation_id = record.owner_id }
    end

  end
  
  def is_admin?
    case record.owner_type
    when 'User'
      user.id == record.owner_id
    else
      user.role_at?(record.owner) == 'admin'
    end
  end
end
