require 'fog'
require_relative 'config'

class AWSResource
  def find_server_by_id(id)
    aws.servers.detect { |server| server.id == id }
  end

  private
  def aws
    @aws ||= Fog::Compute.new(Daemons.config.config_for_fog)
  end
end
