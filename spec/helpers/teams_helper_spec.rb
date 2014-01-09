require 'spec_helper'

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

  describe ".can_add_server?" do
    it "is true when team has no jenkins server" do
      expect(helper).to be_can_add_server(Team.new)
    end

    it "false when team has jenkins_server" do
      team = Team.new
      team.build_jenkins_server
      expect(helper).not_to be_can_add_server(team)
    end
  end
end
