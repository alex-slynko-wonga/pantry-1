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
    if Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, { 'event' => "shutdown_now" }).change_state
      @stop_publisher.publish_message(base_message)
      true
    end
  end

  def start
    if Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, { 'event' => "start_instance" }).change_state
      @start_publisher.publish_message(base_message)
      true
    end
  end

  private

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
