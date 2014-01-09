class UserPolicy < ApplicationPolicy
  def update?
    god_mode?
  end
end

