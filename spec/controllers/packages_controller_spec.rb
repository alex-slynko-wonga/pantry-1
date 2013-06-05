require 'spec_helper'

describe PackagesController do
  describe 'post create' do
    it "creates a package" do
      post :create, { package: {name: 'Name', version: 'Version', url: 'url' }}
      package = Package.last
      package.should be_present
      package.name.should == 'Name'      
    end
  end
end
