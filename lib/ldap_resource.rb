class LdapResource
  def find_user_by_name(name)
    find(Net::LDAP::Filter.eq('sAMAccountName', name))
  end

  def find_user_by_display_name(display_name)
    find(Net::LDAP::Filter.eq('DisplayName', display_name))
  end

  def all_users_from_group(group_name)
    find(Net::LDAP::Filter.eq('memberOf', group_name))
  end

  private
  def find(filter, params = {})
    result = connection.search(params.merge({filter: filter}))
    result || []
  end

  def connection
    @connection ||= Net::LDAP.new(LDAP_CONFIG)
  end
end
