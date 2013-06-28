class SessionsController < ApplicationController
<<<<<<< HEAD
  def new
     
  end

  def create
     auth_hash = request.env['omniauth.auth']   
     render :text => auth_hash.inspect
  end

  def failure
    
   end
=======
  skip_before_filter :signed_in_user, only: :create
  def new
    redirect_to '/auth/ldap'
  end

  def create
    redirect_to 'auth/ldap' and return unless env && env['omniauth.auth']
    user = User.from_omniauth(env['omniauth.auth'])
    session[:user_id]= user.id
    redirect_to root_url, notice: "Signed in!"
  end

  def failure
    redirect_to '/auth/ldap', notice: "Authentication failed, please try again."
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/auth/ldap', notice: "Signed out!"
  end
>>>>>>> c205508d1f8a484555f20e06c9af0b631d54145a
end
