module ApplicationHelper
  def link_to_instance(ec2_instance)
    link_to_if ec2_instance.bootstrapped, "http://#{ec2_instance.name}.#{ec2_instance.domain}", "http://#{ec2_instance.name}.#{ec2_instance.domain}", target: '_blank'
  end

  def navbar_link_to(caption, url)
    content_tag(:li, nil, class: ("active" if current_page?(url))) do
      link_to(caption, url)
    end
  end

  def flash_class(level)
    case level
    when :notice  then "alert alert-info"
    when :success then "alert alert-success"
    when :error   then "alert alert-error"
    when :alert   then "alert alert-error"
    end
  end
  
  def can?(ec2_instance, meth)
    delegated_method = "can_#{meth}?"
    state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance)
    state.state_machine.respond_to?(delegated_method) ? state.state_machine.send(delegated_method) : false
  end
end
