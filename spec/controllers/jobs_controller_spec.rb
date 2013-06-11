require 'spec_helper'

describe JobsController do
  describe 'POST #create' do
    it "creates a job" do
      time_now = Time.local(2000, 1, 1, 1, 0, 0)
      Timecop.freeze(time_now)
      expect{ post :create, {
        name: 'Name', description: 'Description', status: 'Status' }
      }.to change(Job, :count).by(1)
      job = Job.last
      job.should be_present
      job.name.should == 'Name'
      job.description.should == 'Description'
      job.status.should == 'Status'
      job.start_time.should == time_now
    end
  end
end
