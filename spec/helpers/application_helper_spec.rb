require 'spec_helper'

describe ApplicationHelper do
  describe "display_status_image" do 
    it "returns the jenkins url" do 
      instance = FactoryGirl.create(:ec2_instance, bootstrapped: true)
      expect(helper.link_to_instance(instance)).to eq "<a href=\"http://#{instance.name}.#{instance.domain}\">http://#{instance.name}.#{instance.domain}</a>"
    end
    
    it "does not return the jenkins url if it is not bootstrapped" do 
      instance = FactoryGirl.create(:ec2_instance, bootstrapped: false)
      expect(helper.link_to_instance(instance)).to eq "http://#{instance.name}.#{instance.domain}"
    end   
  end  
end
