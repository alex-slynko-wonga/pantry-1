class Wonga::Pantry::Ec2Terminator
  def initialize(ec2_instance, sns = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]["ec2_instance_delete_topic_arn"]))
    @ec2_instance = ec2_instance
    @sns = sns 
  end

  def terminate(user)
    return unless user.teams.include?(@ec2_instance.team)
    if @ec2_instance.running?
      @ec2_instance.terminated_by = user
      @ec2_instance.save
      @sns.publish_message(termination_message)
    end
  end

  private
  def termination_message
    {
      :hostname      => "#{@ec2_instance.name}",
      :domain        => "#{@ec2_instance.domain}",
      :instance_id   => @ec2_instance.instance_id,
      :id            => @ec2_instance.id
    }
  end
end
