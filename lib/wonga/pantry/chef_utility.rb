class Wonga::Pantry::ChefUtility
  def initialize()
    @sqs = Wonga::Pantry::SQSSender.new
  end

  def request_chef_environment(team, queue_name = CONFIG['aws']['chef_env_create_queue_name'])
    @sqs.send_message(team.create_environment_message, queue_name)
  end
end
