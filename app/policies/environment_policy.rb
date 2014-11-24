class EnvironmentPolicy < ApplicationPolicy
  Scope = Struct.new(:user, :scope) do
    def resolve
      scope.available(user).visible
    end
  end
  def permitted_types
    types = Environment::TYPES.dup
    types.delete('CI') if @record.team.ci_environment
    types.delete('CUSTOM') unless god_mode?
    types
  end

  def create?
    god_mode? || team_member?
  end

  def update?
    god_mode? || team_member?
  end

  def hide?
    god_mode? && (@record.hidden != true)
  end

  def update_instances?
    god_mode? || team_member?
  end
end
