OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:ldap, {uid: 'username', extra: { raw_info: OpenStruct.new(samaccountname: ['test_user'])}})

Before do
  visit '/'
end