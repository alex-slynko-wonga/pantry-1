module TeamsHelper
  def os_image(platform)
    if platform == 'windows'
      image_tag 'win_icon.png', title: 'Windows'
    else
      image_tag 'linux_icon.png', title: 'Linux'
    end
  end

  def can_add_server?(team)
    team && team.jenkins_server.nil?
  end
end
