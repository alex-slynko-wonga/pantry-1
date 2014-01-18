class SessionsController < ApplicationController
  force_ssl if: :ssl_needed

  skip_before_action :signed_in_user
  skip_before_action :verify_authenticity_token
  before_action :redirect_to_root, except: [:destroy]

  def new
    redirect_to '/auth/ldap'
  end

  def create
    redirect_to 'auth/ldap' and return unless env && env['omniauth.auth']
    user = User.from_omniauth(env['omniauth.auth']['extra']['raw_info'])
    redirect_to '/auth/ldap' and return unless user
    session[:user_id]= user.id
    redirect_to session['requested_url'] || root_url, notice: "Signed in!"
  end

  def failure
    redirect_to '/auth/ldap', notice: "Authentication failed, please try again."
  end

  def destroy
    session[:user_id] = nil
    session['requested_url'] = nil
    redirect_to '/auth/ldap', notice: "Signed out!"
  end

  private
  def ssl_needed
    CONFIG['pantry']['use_ssl']
  end

  def redirect_to_root
    redirect_to session['requested_url'] || root_url if current_user
  end
end
