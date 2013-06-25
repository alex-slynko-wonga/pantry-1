class ApplicationController < ActionController::Base
protect_from_forgery
  before_filter :authorize
  
  protected
def authorize

end
end