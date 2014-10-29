class ApiController < ActionController::Base
  before_action :check_api_key
  respond_to :json

  def check_api_key
    render json: {}, status: 404 unless request.headers['X-Auth-Token'] == CONFIG['pantry']['api_key']
  end
end
