class ApplicationController < ActionController::Base
  helper_method :current_user, :can?
  protect_from_forgery with: :exception
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
  
  def can?(ec2_instance, meth)
    unless current_user.teams.include?(ec2_instance.team)
      return false
    end        
    delegated_method = "can_#{meth}?"
    state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance)
    state.state_machine.respond_to?(delegated_method) ? state.state_machine.send(delegated_method) : false
  end
end

