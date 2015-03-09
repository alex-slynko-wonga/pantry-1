class JenkinsSlavePolicy < ApplicationPolicy
  def create?
    (god_mode? || (team_member? && !maintenance_mode?)) && @record.jenkins_server.ec2_instance.state == 'ready'
  end

  Scope = Struct.new(:user, :scope) do
    def resolve
      scope
    end
  end
end
