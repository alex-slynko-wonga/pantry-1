require 'spec_helper'

describe Wonga::Pantry::Costs do
  let(:bill_date) { Date.today.prev_month.end_of_month }
  subject { Wonga::Pantry::Costs.new(bill_date) }

  describe '#costs_per_team' do
    let!(:team) { FactoryGirl.create(:team) }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }

    it "returns array of hashes with total costs for current bill date only" do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date + 1, ec2_instance: ec2_instance, cost: 50)
      result = subject.costs_per_team
      expected = [{"id" => team.id, "name" => team.name, "costs" => 100.to_d } ]
      expect(result).to eq(expected)
    end

    it "returns array of hashes with 0 if team has no reported costs" do
      result = subject.costs_per_team
      expected = [{"id" => team.id, "name" => team.name, "costs" => 0.to_d } ]
      expect(result).to eq(expected)
    end

    it "returns array of hashes with total costs for all instances" do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: FactoryGirl.create(:ec2_instance, team: team), cost: 50)
      result = subject.costs_per_team
      expected = [{"id" => team.id, "name" => team.name, "costs" => 150.to_d } ]
      expect(result).to eq(expected)
    end
  end

  describe "#bill_date" do
    it "is same as provided to constructor" do
      expect(subject.bill_date).to eq(bill_date)
    end

    context "when it is not passed" do
      subject { Wonga::Pantry::Costs.new(nil) }

      it "is end of current month" do
        bill_date = Date.today.end_of_month
        Date.stub(:today).and_return(mock(end_of_month: bill_date))
        expect(subject.bill_date).to eq(bill_date)
      end
    end

    context "when it is passed as a string" do
      subject { Wonga::Pantry::Costs.new(bill_date.to_s) }

      it "is parsed to date" do
        expect(subject.bill_date).to eq(bill_date)
      end
    end
  end
end

