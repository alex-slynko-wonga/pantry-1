require 'spec_helper'

describe "authorization" do
  ["/", "/jobs", "/jobs/1", "/packages", "/chef_nodes/search"].each do |url|
    describe "visiting #{url}" do
      pending("implementation of authorization logic in controllerfor #{url}")
      #before { get url }
      #specify { expect(response).to redirect_to(login) }
    end
  end
end