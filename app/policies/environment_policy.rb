class EnvironmentPolicy < ApplicationPolicy
  def permitted_types
    types = Environment::TYPES.dup
    types.delete('CI') if @record.team.ci_environment
    types.delete('CUSTOM') unless god_mode?
    types
  end

  def create?
    god_mode? || team_member?
  end
end
