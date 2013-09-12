module ApplicationHelper
  def link_to_instance(ec2_instance)
    link_to_if ec2_instance.bootstrapped, "http://#{ec2_instance.name}.#{ec2_instance.domain}", "http://#{ec2_instance.name}.#{ec2_instance.domain}", target: '_blank'
  end
end
