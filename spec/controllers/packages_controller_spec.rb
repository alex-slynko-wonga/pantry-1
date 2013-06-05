require 'spec_helper'

describe PackagesController do
  describe 'POST #create' do
    it "creates a package" do
      expect{ post :create, {
        name: 'Name', version: 'Version', url: 'url' }
      }.to change(Package, :count).by(1)
      package = Package.last
      package.should be_present
      package.name.should == 'Name'
    end
  end
end
