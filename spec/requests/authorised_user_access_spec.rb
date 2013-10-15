require 'spec_helper'

describe "authorization" do
  ["/", "/teams", "/jenkins_servers"].each do |url|
    describe "visiting #{url}" do
      before { get url }
      specify { expect(response).to redirect_to('/auth/ldap') }
    end
  end
end
