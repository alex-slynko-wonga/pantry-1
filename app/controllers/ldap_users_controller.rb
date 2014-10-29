class LdapUsersController < ApplicationController
  respond_to :json

  def index
    users = LdapResource.new.filter_by_name(params[:term] + '*').all.map do |ldap_user|
      { value: ldap_user['samaccountname'].first, label: ldap_user['displayname'].first }
    end

    respond_with users
  end
end
