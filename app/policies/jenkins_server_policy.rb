class JenkinsServerPolicy < ApplicationPolicy
  def create?
    (god_mode? || team_member?) && (@record.team.jenkins_server.nil? || @record.team.jenkins_server.new_record?)
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
