class UsersController < ApplicationController
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
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
        format.html do
          flash[:success] = 'User updated'
          redirect_to @user
        end
        format.json do
          render json: @user, status: :updated, location: @user
        end
        flash[:success] = 'User updated successfully'
      else
        format.html do
          flash[:error] = 'User update failed!'
          redirect_to @user
        end
        format.json do
          render json: @user.errors, status: :unprocessable_entity
        end
        flash[:error] = "User updating failed: #{user.errors.full_messages.to_sentence}"
      end
    end
  end
end
