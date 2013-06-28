OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:ldap, {uid: 'username', extra: { raw_info: {samaccountname: ['test_user'], displayname: ['name']}}})

Before do
  visit '/'
end

