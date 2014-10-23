module ApplicationHelper
  def link_to_instance(ec2_instance)
    link_to_if ec2_instance.state=="ready", instance_canonical_url(ec2_instance), instance_canonical_url(ec2_instance), target: '_blank'
  end

  def link_to_instance_role(ec2_instance)
    link_to_if policy(current_user).admin?, ec2_instance.instance_role.display_name, admin_instance_role_path(ec2_instance.instance_role)
  end

  def navbar_link_to(caption, url)
    content_tag(:li, nil, class: ("active" if current_page?(url))) do
      link_to(caption, url)
    end
  end

  def instance_canonical_url(ec2_instance)
    "http://#{ec2_instance.name}.#{ec2_instance.domain}"
  end

  def flash_class(level)
    case level
    when :notice  then "alert alert-info"
    when :success then "alert alert-success"
    when :error   then "alert alert-error"
    when :alert   then "alert alert-error"
    end
  end
end
