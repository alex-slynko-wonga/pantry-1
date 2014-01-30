class Api::Teams::ChefEnvironmentsController < ApiController
  respond_to :json
  def update
    environment = Environment.where(team_id: params[:team_id]).find params[:id]
    environment.update_attributes(chef_environment: params[:chef_environment])

    respond_with environment
  end
end
