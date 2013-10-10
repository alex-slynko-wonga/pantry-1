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
describe Ec2InstanceStatusesHelper do
  describe "display_status_image" do 
    it "displays a cross for a false value status" do 
      expect(helper.display_status_image(false)).to eq(image_tag("/assets/cross.png"))
    end

    it "displays a tick for a true value status" do 
      expect(helper.display_status_image(true)).to eq(image_tag("/assets/tick.png"))
    end

    it "displays a spinner for a nil value status" do 
      expect(helper.display_status_image(nil)).to eq(image_tag("/assets/spinner.gif"))
    end
  end
end
