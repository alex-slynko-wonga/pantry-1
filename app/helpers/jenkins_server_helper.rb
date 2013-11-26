module JenkinsServerHelper
  def can_add_server?(team)
    return false if team.nil?
    team.jenkins_server.nil?
  end
end
