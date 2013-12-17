class UsersController < ApplicationController
  def index
    @users = User.all
 
    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => @users }
    end
  end

  def show
    @user = User.find(params[:id])
    @ec2_instances = Ec2Instance.where(user_id:params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.username = params[:username]
    @user.save
    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user,
                      :notice => "User updated" ) }
        format.json { render :json => @user,
                      :status => :updated, :location => @user  }
        flash[:notice] = "User updated successfully"
      else
        format.html { redirect_to(@user,
                      :notice => "User update failed!" ) }
        format.json { render :json => @user.errors,
                      :status => :unprocessable_entity  }
        flash[:error] = "User updating failed: #{user.errors.full_messages.to_sentence}"
      end
    end
  end
end
