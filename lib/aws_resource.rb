class AWSResource
  def find_server_by_id(id)
    aws.servers.detect { |server| server.id == id }
  end

  private
  def aws
    @aws ||= Fog::Compute.new(provider: 'AWS')
  end
end
