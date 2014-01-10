class JenkinsSlavePolicy < ApplicationPolicy
  def create?
    (god_mode? || @user.teams.include?(@record.team)) && @record.jenkins_server.ec2_instance.state == 'ready'
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
