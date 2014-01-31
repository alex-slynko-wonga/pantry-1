class Wonga::Pantry::Ec2Resource
  def initialize( instance,
                  user,
                  start_publisher = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]['ec2_instance_start_topic_arn']),
                  stop_publisher  = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]['ec2_instance_stop_topic_arn']) )
    @start_publisher  = start_publisher
    @stop_publisher   = stop_publisher
    @ec2_instance     = instance
    @user             = user
  end

  def stop
    change("shutdown_now", @stop_publisher)
  end

  def start
    change("start_instance", @start_publisher)
  end

  def terminate(sns = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]["ec2_instance_delete_topic_arn"]))
    change('termination', sns)
  end

  def boot(sns = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]["ec2_instance_boot_topic_arn"]))
    change('ec2_boot', sns, Wonga::Pantry::BootMessage.new(@ec2_instance).boot_message)
  end

  def change(event, publisher, message=base_message)
    if state_machine(event).change_state
      publisher.publish_message(message)
      true
    end
  end

  private

  def state_machine(event)
     Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, { 'event' => event })
  end

  def base_message
    {
      hostname:    @ec2_instance.name,
      domain:      @ec2_instance.domain,
      instance_id: @ec2_instance.instance_id,
      id:          @ec2_instance.id,
      user_id:     @user.id
    }
  end
end
