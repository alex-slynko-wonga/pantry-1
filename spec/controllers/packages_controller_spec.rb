require 'spec_helper'

describe PackagesController do
  let (:user) { FactoryGirl.create(:user) }

  before :each do
    session[:user_id] = user.id
  end
  
  describe 'POST #create' do
    it "creates a package" do
      expect{ post :create, {
        name: 'Name', version: 'Version', url: 'url', bag_title: 'DataBag', item_title: 'DataItem' }
      }.to change(Package, :count).by(1)
      package = Package.last
      package.should be_present
      package.name.should == 'Name'
    end
  end
end
