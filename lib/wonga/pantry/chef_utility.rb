class Wonga::Pantry::ChefUtility
  def initialize()
    @sqs = Wonga::Pantry::SQSSender.new
  end

  def request_chef_environment(team, queue_name = CONFIG['aws']['chef_env_create_queue_name'])
    @sqs.send_message(create_environment_message(team), queue_name)
  end

  def create_environment_message(team)
    {
      team_name:          team.name,
      id:                 team.id,
      domain:             CONFIG['pantry']['domain'],
    }
  end
end
