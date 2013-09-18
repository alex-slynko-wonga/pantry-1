class Api::Teams::ChefEnvironmentsController < ApiController
  def create
    team = Team.find(params[:team_id]).update_attributes(chef_environment: params[:chef_environment])

    respond_with [:api, team]
  end
end
