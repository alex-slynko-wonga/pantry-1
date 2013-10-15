class Wonga::Pantry::Ec2Terminator
  def initialize(ec2_instance, sqs = Wonga::Pantry::SQSSender.new(CONFIG["aws"]["terminate_queue_name"]))
    @ec2_instance = ec2_instance
    @sqs = sqs
  end

  def terminate(user)
    return unless user.teams.include?(@ec2_instance.team)
    if @ec2_instance.running?
      @ec2_instance.terminated_by = user
      @ec2_instance.save
      @sqs.send_message(termination_message)
    end
  end

  private
  def termination_message
    {
      node: "#{@ec2_instance.name}.#{@ec2_instance.domain}",
      instance_id: @ec2_instance.instance_id,
      id: @ec2_instance.id
    }
  end
end
