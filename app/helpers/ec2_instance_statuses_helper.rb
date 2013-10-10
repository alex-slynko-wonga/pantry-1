module Ec2InstanceStatusesHelper
  def display_status_image(status)
    case status
    when nil
      image_tag('spinner.gif')
    when true
      image_tag('tick.png')
    else
      image_tag('cross.png')
    end
  end
end
