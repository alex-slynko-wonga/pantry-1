class Admin::AdminController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    # security through obscurity
    render file: "#{Rails.root}/public/404.html", status: :not_found unless policy(current_user).admin?
  end
end
