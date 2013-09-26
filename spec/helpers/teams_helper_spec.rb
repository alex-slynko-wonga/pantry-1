require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the Ec2InstanceStatusHelper. For example:
#
# describe Ec2InstanceStatusHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe TeamsHelper do
  describe "os_image" do 
    it "displays the linux icon" do 
      expect(helper.os_image(nil)).to include "src=\"/assets/linux_icon.png\""
    end
    
    it "displays the windows icon" do 
      expect(helper.os_image('windows')).to include "src=\"/assets/win_icon.png\""
    end
  end
  
  describe "os_image" do 
    it "displays the link" do 
      expect(helper.create_new_ec2_instance(true)).to include "Launch New Instance"
    end
    
    it "does not display the link" do 
      helper.create_new_ec2_instance(false).should be_nil
    end
  end
end
