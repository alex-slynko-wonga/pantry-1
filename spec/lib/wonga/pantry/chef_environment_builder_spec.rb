require 'spec_helper'

describe Wonga::Pantry::ChefEnvironmentBuilder do
  let(:team_name) { 'some-name' }
  let(:team) { FactoryGirl.build(:team, name: team_name) }
  let(:domain) { 'test-domain' }
  subject { described_class.new(team, domain) }

  describe "#chef_environment" do
    it "returns prepared name" do
      expect(subject.chef_environment).to eq('some-name')
    end
  end

  describe "#build!" do
    before(:each) do
      subject.build!
    end

    let(:environment) { Chef::Environment.load("some-name") }
    %w( authorization build_agent build_essential jenkins nginx openssh).each do |group|
      it "creates new Chef environment with #{group} information" do
        expect(environment.default_attributes).to have_key(group)
      end
    end

    it "sets address for jenkins" do
      jenkins = environment.default_attributes['jenkins']['server']
      expect(jenkins['host']).to eq "#{team_name}.#{domain}"
      expect(jenkins["url"]).to include("#{team_name}.#{domain}")
    end

    context "for team with restricted symbols in name" do
      let(:team_name) { 'so .,+me_name?' }

      it "creates new Chef environment" do
        expect(environment).not_to be_nil
      end
    end
  end
end


