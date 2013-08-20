require 'spec_helper'

describe Wonga::Pantry::ChefEnvironmentBuilder do
  let(:team_name) { 'some-name' }
  let(:team) { FactoryGirl.build(:team, name: team_name) }
  subject { described_class.new(team) }

  describe "#build!" do
    before(:each) do
      subject.build!
    end

    let(:environment) { Chef::Environment.load("some-name-env") }
    %w( authorization build_agent build_essential jenkins).each do |group|
      it "creates new Chef environment with #{group} information" do
        expect(environment.default_attributes).to have_key(group)
      end
    end

    it "sets address for jenkins" do
      jenkins = environment.default_attributes['jenkins']['server']
      expect(jenkins['host']).to eq "#{team_name}.example.com"
      expect(jenkins["url"]).to include("#{team_name}.example.com")
    end

    context "for team with restricted symbols in name" do
      let(:team_name) { 'so .,+me_name?' }

      it "creates new Chef environment" do
        expect(environment).not_to be_nil
      end
    end
  end
end


