class TeamPolicy < ApplicationPolicy
  def update?
    god_mode? || user.teams.include?(record)
  end
end
