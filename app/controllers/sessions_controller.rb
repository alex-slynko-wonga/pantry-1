class SessionsController < ApplicationController
  force_ssl if: :ssl_needed
  layout false, only: [:new, :failure]

  skip_before_action :signed_in_user
  skip_before_action :verify_authenticity_token
  before_action :redirect_to_root, except: [:destroy]

  def new
  end

  def create
    redirect_to('auth/ldap') && return unless env && env['omniauth.auth']
    user = User.from_omniauth(env['omniauth.auth']['extra']['raw_info'])
    redirect_to('/auth/ldap') && return unless user
    requested_url = session['requested_url'] || root_url
    reset_session
    session[:user_id] = user.id
    flash[:success] = 'Signed in!'
    redirect_to requested_url
  end

  def failure
    flash[:error] = 'Authentication failed, please try again!'
    redirect_to request.referer
  end

  def destroy
    session[:user_id] = nil
    session['requested_url'] = nil
    flash[:success] = 'Signed out!'
    redirect_to '/auth/ldap'
  end

  private

  def ssl_needed
    CONFIG['pantry']['use_ssl']
  end

  def redirect_to_root
    return unless current_user
    page = session['requested_url'] || root_url
    page = root_url if page['/auth']
    session['requested_url'] = nil
    redirect_to page
  end
end
