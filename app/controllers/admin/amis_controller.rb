class Admin::AmisController < Admin::AdminController
  def index
    @amis = Ami.all
  end

  def show
    @ami = Ami.find_by_ami_id(params[:id])

    render json: @ami
  end

  def new
    @angular_action = 'addAmi'
    @ami = Ami.new
  end

  def update
    @ami = Ami.find_by_ami_id(params[:id])

    if @ami.update_attributes(name: params[:name], hidden: params[:hidden])
      render json: @ami
    else
      render json: @ami.errors, status: :unprocessable_entity
    end
  end

  def create
    @ami = Ami.new(ami_id:   params[:ami_id],
                   name:     params[:name],
                   hidden:   params[:hidden],
                   platform: params[:platform]
    )

    if @ami.save
      render json: @ami
    else
      render json: @ami.errors, status: :unprocessable_entity
    end
  end

  def edit
    @angular_action = 'updateAmi'
    @ami = Ami.find(params[:id])
  end

  def destroy
    Ami.find(params[:id]).destroy
    redirect_to admin_amis_url
  end
end
