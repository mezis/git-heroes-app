class SessionPolicy < ApplicationPolicy
  def update?
    user&.admin?
  end
end
