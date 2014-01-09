class UsersController < ApplicationController
  def index
    @users = User.all

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => @users }
    end
  end

  def show
    @user = User.includes(:ec2_instances).find(params[:id])
  end

  def edit
    authorize(@user = User.find(params[:id]))
  end

  def update
    authorize(@user = User.find(params[:id]))
    @user.role = params[:user][:role]

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
