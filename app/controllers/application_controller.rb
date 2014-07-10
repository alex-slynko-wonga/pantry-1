class ApplicationController < ActionController::Base
  include Pundit

  helper_method :current_user
  protect_from_forgery with: :exception
  before_action :signed_in_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    session[:user_id].present?
  end

  def signed_in_user
    if http_get? && !auth_request?
      session['requested_url'] = request.url
    end
    redirect_to '/auth/ldap', notice: "Please sign in." unless signed_in?
  end

  def pundit_user
    user = User.where(username: params[:test_user]).first if current_user.role == "superadmin" && params[:test_user]
    user || current_user
  end

  def human_errors(model)
    model.errors.full_messages.to_sentence
  end

  private

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to root_path
  end

  def http_get?
    request.get? && !request.xhr? && params['format'] != 'json'
  end

  def auth_request?
    request.fullpath['/auth/']
  end
end

