class ApplicationController < ActionController::Base
  helper_method :current_user
  protect_from_forgery
  before_filter :signed_in_user
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    session[:user_id].present?
  end

  def signed_in_user
    session['requested_url'] = request.url
    redirect_to '/auth/ldap', notice: "Please sign in." unless signed_in?
  end
end