require 'spec_helper'

describe Ec2InstanceStatusesController do
  let(:instance) { FactoryGirl.create(:ec2_instance) }
  
  describe "GET 'show'" do
    it "returns http success with a html request" do
      get 'show', id: instance.id
      response.should be_success
    end
    
    it "returns a json hash" do
      expected = { ami: instance.ami,
                    booted: instance.booted,
                    bootstrapped: instance.bootstrapped,
                    chef_environment: instance.chef_environment,
                    created_at: instance.created_at,
                    domain: instance.domain,
                    end_time: instance.end_time,
                    flavor: instance.flavor,
                    id: instance.id,
                    instance_id: instance.instance_id,
                    joined: instance.joined,
                    name: instance.name,
                    platform: instance.platform,
                    run_list: instance.run_list,
                    security_group_ids: instance.security_group_ids,
                    start_time: instance.start_time,
                    subnet_id: instance.subnet_id,
                    team_id: instance.team_id,
                    updated_at: instance.updated_at,
                    user_id: instance.user_id
      }.to_json
      get 'show', id: instance.id, format: :json
      response.body.should == expected
    end
  end
end