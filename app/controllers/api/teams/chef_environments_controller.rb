class Api::Teams::ChefEnvironmentsController < ApiController
  respond_to :json
  def create
    team = Team.find(params[:team_id])
    team.update_attributes(chef_environment: params[:chef_environment])

    respond_with team
  end
end
