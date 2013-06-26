require 'spec_helper'

describe JobsController do
  let (:user) { FactoryGirl.create(:user) }

  before :each do
    session[:user_id] = user.id
  end
  describe 'POST #create' do
    it "creates a job" do
      expect{ post :create, {
        name: 'Name', description: 'Description', status: 'pending' }
      }.to change(Job, :count).by(1)
      job = Job.last
      job.should be_present
      job.name.should == 'Name'
      job.description.should == 'Description'
      job.status.should == 'pending'
    end
  end
end
