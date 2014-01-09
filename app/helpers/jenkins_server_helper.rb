module JenkinsServerHelper
  def link_to_new_slave(jenkins_server)
    if policy(jenkins_server.jenkins_slaves.build).create?
      link_to "Create a new slave", new_jenkins_server_jenkins_slave_path(jenkins_server)
    end
  end
end
