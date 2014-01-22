class EnvironmentPolicy < ApplicationPolicy
  def create?
    god_mode? || team_member?
  end
end
