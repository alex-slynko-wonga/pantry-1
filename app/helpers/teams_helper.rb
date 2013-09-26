module TeamsHelper
  def os_image(platform)
    if platform == 'windows'
      image_tag 'win_icon.png', title: 'Windows'
    else
      image_tag 'linux_icon.png', title: 'Linux'
    end
  end
  
  def create_new_ec2_instance(show_link)
    render 'new_ec2_instance_link' if show_link
  end
end
