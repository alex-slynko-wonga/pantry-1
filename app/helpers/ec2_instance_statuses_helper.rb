module Ec2InstanceStatusesHelper
  def display_status_image(status)
    status ? image_tag("tick.png") : image_tag("spinner.gif")
  end
end
