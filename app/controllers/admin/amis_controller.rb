class Admin::AmisController < Admin::AdminController
  def index
    @amis = Ami.all
  end

  def new
    @ami = Ami.new
  end

  def update
    @ami = Ami.find(params[:id])

    if @ami.update_attributes(ami_attributes)
      redirect_to admin_amis_path
      flash[:notice] = 'AMI updated successfully'
    else
      flash[:error] = "AMI update failed: #{human_errors(@ami)}"
      redirect_to edit_admin_ami_url(@ami)
    end
  end

  def create
    @ami = Ami.new(ami_attributes)

    if @ami.save
      redirect_to admin_amis_path
    else
      render :new
    end
  end

  def edit
    @ami = Ami.find(params[:id])
    @ami_platform_was = @ami.platform
  end

  def destroy
    Ami.destroy(params[:id])
    redirect_to admin_amis_path
  end

  private

  def ami_attributes
    params.require(:ami).permit(:ami_id, :name, :hidden, :platform, :bootstrap_username)
  end
end
