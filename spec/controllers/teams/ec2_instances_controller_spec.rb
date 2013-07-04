require 'spec_helper'

describe Teams::Ec2InstancesController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', team_id: 1, :format => :json
      response.should be_success
    end
  end

end
