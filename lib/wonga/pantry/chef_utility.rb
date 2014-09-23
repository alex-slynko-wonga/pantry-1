class Wonga::Pantry::ChefUtility
  def initialize
    @sqs = Wonga::Pantry::SQSSender.new(CONFIG['aws']['chef_env_create_queue_name'])
  end

  def request_chef_environment(team, environment)
    @sqs.send_message(environment_message(team, environment))
  end

  def environment_message(team, environment)
    {
      team_name:               team.name,
      team_id:                 team.id,
      environment_id:          environment.id,
      environment_name:        environment.name,
      environment_description: environment.description,
      environment_type:        environment.environment_type,
      domain:                  CONFIG['pantry']['domain'],
      users:                   team.users.map(&:username)
    }
  end
end
