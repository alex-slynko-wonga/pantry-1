Rails.application.config.middleware.use OmniAuth::Strategies::LDAP,
        :title => "Pantry LDAP Login",
        :host => "ldap.example.com",
        :port => 3268,
        :method => :plain,
        :base => "dc=example,dc=com",
        :uid => "sAMAccountName",
        :bind_dn => "ProvisionerUsername@example.com",
        :password => "ProvisionerPassword"

#omniauth failure redirect doesn't work in dev mode. fix below.
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}


