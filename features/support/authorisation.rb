OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:ldap, uid: 'username',
                                extra: {
                                  raw_info:
                                  {
                                    samaccountname: ['test_user'],
                                    displayname: ['name'],
                                    memberof: [CONFIG['omniauth']['ldap_group']]
                                  }
                                })

Before do
  visit '/'
end
