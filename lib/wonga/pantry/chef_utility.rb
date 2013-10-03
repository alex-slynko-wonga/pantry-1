class Wonga::Pantry::ChefUtility
  def initialize()
    @sqs = Wonga::Pantry::SQSSender.new(CONFIG['aws']['chef_env_create_queue_name'])
  end

  def request_chef_environment(team)
    @sqs.send_message(environment_message(team))
  end

  def environment_message(team)
    {
      team_name:          team.name,
      team_id:            team.id,
      domain:             CONFIG['pantry']['domain'],
    }
  end
end
