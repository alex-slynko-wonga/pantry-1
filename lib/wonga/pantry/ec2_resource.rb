class Wonga::Pantry::Ec2Resource
  def initialize(instance, user)
    @start_topic      = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]['start_machine_topic_name']) 
    @stop_topic       = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]['stop_machine_topic_name']) 
    @terminate_topic  = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]['terminate_machine_topic_name'])  
    @ec2_instance     = instance
    @user             = user 
  end

  def stop
    if Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, { 'event' => "shutdown_now" }).change_state
      @stop_topic.publish_message(base_message)
    end
  end

  def start
    if Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, { 'event' => "start_instance" }).change_state
      @start_topic.publish_message(base_message)
    end
  end

  def terminate
    if Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, { 'event' => "termination" }).change_state
      @terminate_topic.publish_message(base_message)
    end
  end

  private

  def base_message
    {
      :hostname      => @ec2_instance.name,
      :domain        => @ec2_instance.domain,
      :instance_id   => @ec2_instance.instance_id,
      :id            => @ec2_instance.id
    }
  end
end
