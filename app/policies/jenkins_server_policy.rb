class JenkinsServerPolicy < ApplicationPolicy
  def create?
    (god_mode? || @user.teams.include?(@record.team)) && (@record.team.jenkins_server.nil? || @record.team.jenkins_server.new_record?)
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
