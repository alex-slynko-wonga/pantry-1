require 'spec_helper'

describe Ec2InstanceCost do
  subject { FactoryGirl.build(:ec2_instance_cost) }
  it { should be_valid }
  
  describe "#get_available_dates" do
    it "returns the grouped dates of the entries" do
      # days must be the last of the month
      FactoryGirl.create(:ec2_instance_cost, bill_date: Date.new(2013, 10, 31))
      FactoryGirl.create(:ec2_instance_cost, bill_date: Date.new(2013, 11, 30))
      FactoryGirl.create(:ec2_instance_cost, bill_date: Date.new(2013, 11, 30))
      dates = Ec2InstanceCost.get_available_dates
      expect(dates.size).to eq(2) # Novermber dates becomes one, then we have October
      expect(dates.first).to eq(Date.new(2013, 11, 30)) # reverse method puts the lastest date first in the array
      expect(dates.last).to eq(Date.new(2013, 10, 31))
    end
  end
end
