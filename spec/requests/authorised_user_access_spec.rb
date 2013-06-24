require 'spec_helper'

describe "authorization" do
  
  describe "for unauthenticated users" do
    let(:user) { FactoryGirl.create(:user) }

    describe "visiting the home page" do
      before { visit root }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the job page" do
      before { visit  }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the jobs page" do
      before { visit jobs }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the job log page" do
      before { visit job_job_log }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the job logs page" do
      before { visit job_job_logs }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the packages page" do
      before { visit packages }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the data bags page" do
      before { visit data_bags }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the search chef nodes page" do
      before { visit search_chef_nodes }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the chef nodes page" do
      before { visit chef_nodes }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the new chef node page" do
      before { visit new_chef_node }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the edit chef node page" do
      before { visit edit_chef_node }
      specify { response.should redirect_to(login) }
    end
    
    describe "visiting the chef node page" do
      before { visit chef_node }
      specify { response.should redirect_to(login) }
    end
    
  end
end
