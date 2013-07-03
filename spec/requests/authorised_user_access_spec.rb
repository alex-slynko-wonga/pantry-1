require 'spec_helper'

describe "authorization" do
  ["/", "/jobs", "/jobs/1", "/packages", "/chef_nodes/search"].each do |url|
    describe "visiting #{url}" do
      before { get url }
      specify { expect(response).to redirect_to('/auth/ldap') }
    end
  end
end
