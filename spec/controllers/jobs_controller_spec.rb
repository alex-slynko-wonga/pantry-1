require 'spec_helper'

describe JobsController do
  describe 'POST #create' do
    it "creates a job" do
      expect{ post :create, {
        name: 'Name', description: 'Description', status: 'Status' }
      }.to change(Job, :count).by(1)
      job = Job.last
      job.should be_present
      job.name.should == 'Name'
      job.description.should == 'Description'
      job.status.should == 'Status'
    end
  end
end
