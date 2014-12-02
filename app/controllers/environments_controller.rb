class EnvironmentsController < ApplicationController
  before_action :load_team, only: [:new, :create, :index]
  before_action :load_environment, only: [:show, :edit, :update, :hide, :update_instances]

  def index
    @environments = @team.environments
  end

  def new
    @environment = @team.environments.build(environment_type: params[:environment_type])
    session[:return_to] ||= request.referer
  end

  def create
    @environment = @team.environments.build(environment_parameters)
    authorize(@environment)
    if @environment.save
      chef_utility = Wonga::Pantry::ChefUtility.new
      chef_utility.request_chef_environment(@team, @environment)
      flash[:success] = 'Environment created'
      redirect_to session.delete(:return_to) || @team
    else
      flash[:error] = "Environment creation failed: #{human_errors(@environment)}"
      render('new')
    end
  end

  def show
    @ec2_instances = @environment.ec2_instances
  end

  def edit
    authorize(@environment)
  end

  def update
    authorize(@environment)
    if @environment.update_attributes(environment_update_parameters)
      redirect_to @environment
      flash[:success] = 'Environment updated successfully'
    else
      flash[:error] = "Environment update failed: #{human_errors(@environment)}"
      render :edit
    end
  end

  def hide
    authorize(@environment)

    if @environment.hide
      flash[:success] = 'Environment was hidden successfully'
    else
      flash[:error] = "Environment was not hidden with errors: #{human_errors(@environment)}"
    end

    redirect_to @environment
  end

  def update_instances
    authorize(@environment)
    ec2_instances = Ec2Instance.where(environment_id: @environment.id)
    @changed_instances = 0
    ec2_instances.each do |ec2_instance|
      if (params[:event] == 'shutdown_now' && policy(ec2_instance).shutdown_now?) ||
          (params[:event] == 'start_instance' && policy(ec2_instance).start_instance?)
        update_instance(ec2_instance)
      end
    end

    if params[:event] == 'shutdown_now'
      flash[:notice] = "Shutting down #{@changed_instances} of #{ec2_instances.count} instances"
    else
      flash[:notice] = "Starting #{@changed_instances} of #{ec2_instances.count} instances"
    end

    redirect_to @environment
  end

  private

  def update_instance(ec2_instance)
    ec2_resource = Wonga::Pantry::Ec2Resource.new(ec2_instance, current_user)

    if params[:event] == 'shutdown_now'
      @changed_instances += 1 if ec2_resource.stop
    elsif params[:event] == 'start_instance'
      @changed_instances += 1 if ec2_resource.start
    end
  end

  def environment_parameters
    params.require('environment').permit(:name, :description, :environment_type)
  end

  def environment_update_parameters
    params.require('environment').permit(:name, :description)
  end

  def load_team
    @team = Team.find(params[:team_id])
  end

  def load_environment
    @environment = Environment.find(params[:id])
  end
end
