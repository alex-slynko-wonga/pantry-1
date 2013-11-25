require 'spec_helper'

describe ApplicationHelper do
  describe "display_status_image" do
    it "returns the jenkins url" do
      instance = FactoryGirl.create(:ec2_instance, bootstrapped: true)
      expect(helper.link_to_instance(instance)).to eq "<a href=\"http://#{instance.name}.#{instance.domain}\" target=\"_blank\">http://#{instance.name}.#{instance.domain}</a>"
    end

    it "does not return the jenkins url if it is not bootstrapped" do
      instance = FactoryGirl.create(:ec2_instance, bootstrapped: false)
      expect(helper.link_to_instance(instance)).to eq "http://#{instance.name}.#{instance.domain}"
    end
  end

  describe "flash_class" do
    it "returns 'alert alert-info' when flash is :notice" do
      expect(helper.flash_class(:notice)).to eq "alert alert-info"
    end

    it "returns 'alert alert-success' when flash is :success" do
      expect(helper.flash_class(:success)).to eq "alert alert-success"
    end

    it "returns 'alert alert-error' when flash is :error" do
      expect(helper.flash_class(:error)).to eq "alert alert-error"
    end

    it "returns 'alert alert-error' when flash is :alert" do
      expect(helper.flash_class(:alert)).to eq "alert alert-error"
    end
  end

  describe "navbar_link_to" do
    it "generates li with active class and link if current page is selected" do
      expect(helper.navbar_link_to("Home", "https://pantry.example.com/")).to eq("<li><a href=\"https://pantry.example.com/\">Home</a></li>")
    end

    it "generates li with active class and link if current page is selected" do
      helper.stub(:current_page?).and_return(true)
      expect(helper.navbar_link_to("Home", "https://pantry.example.com/")).to eq("<li class=\"active\"><a href=\"https://pantry.example.com/\">Home</a></li>")
    end
  end
  
  describe "can?" do
    it "returns true if :termination is passed and the instance state is 'ready'" do
      expect(helper.can?(FactoryGirl.build(:ec2_instance, state: 'ready'), :termination)).to be_true
    end

    it "returns false if :terminated state is passed and the instance state is 'ready'" do
      expect(helper.can?(FactoryGirl.build(:ec2_instance, state: 'ready'), :terminated)).to be_false
    end
  end
end
