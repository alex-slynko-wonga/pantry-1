class ApiController < ActionController::Base
  before_action :check_api_key
  respond_to :json

  def check_api_key
    api_key = ApiKey.where(key: request.headers['X-Auth-Token']).first
    if api_key
      # get all permissions for current api_key
      permissions = Rails.application.routes.named_routes.routes.values.select { |node| api_key.permissions.include? node.name }

      return if permissions.any? do |node| # whether the request contains the required permissions
        node.defaults[:controller] == request.parameters['controller'] && node.defaults[:action] == request.parameters['action']
      end
    end
    render json: {}, status: 404
  end
end
