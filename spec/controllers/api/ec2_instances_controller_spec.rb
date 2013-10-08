require 'spec_helper'

describe Api::Ec2InstancesController do

  describe "#create" do

    context "with valid token" do
      before(:each) do
        request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
        @ec2_instance = instance_double('Ec2Instance', id: 45)
        Ec2Instance.stub(:find).with('45').and_return(@ec2_instance)
      end

      it "updates an instance" do
        @ec2_instance.should_receive(:complete!)
        put :update, id: 45, terminated: true, format: 'json'
      end
    end
  end
end
