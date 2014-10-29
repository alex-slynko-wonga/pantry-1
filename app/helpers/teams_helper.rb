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

  def teams_toggle_link(inactive)
    return unless policy(Team).see_inactive_teams?
    if inactive
      link_to 'show only active teams', teams_url
    else
      link_to 'show only inactive teams', teams_url(inactive: true)
    end
  end

  def teams_header(inactive)
    inactive ? 'Inactive teams' : 'Teams'
  end
end
