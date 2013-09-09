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
    #THIS IS A HAAAACK!!!!!
    #Due to time limits we are using a hard coded API Tocken
    #TD-966 was added to the backlog to redress this woeful wrong
    if request.headers['X-Auth-Token'] == CONFIG['pantry']['api_key']
      session[:user_id] = User.first.id
    end
    session['requested_url'] = request.url
    redirect_to '/auth/ldap', notice: "Please sign in." unless signed_in?
  end
end

