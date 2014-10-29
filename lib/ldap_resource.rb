class LdapResource
  def initialize
    filter_by_group(CONFIG['omniauth']['ldap_group'])
  end

  def filter_by_name(name)
    filters << (Net::LDAP::Filter.eq('sAMAccountName', name) | Net::LDAP::Filter.eq('DisplayName', name))
    self
  end

  def filter_by_group(group_name)
    filters << Net::LDAP::Filter.ex('memberOf:1.2.840.113556.1.4.1941', group_name)
    self
  end

  def all(params = {})
    find(params)
  end

  private

  def filters
    @filters ||= []
  end

  def find(params = {})
    connection.search(params.merge(filter: filters.inject { |result, filter| result & filter })) || []
  end

  def connection
    @connection ||= Net::LDAP.new(LDAP_CONFIG)
  end
end
