require 'spec_helper'

describe Wonga::Pantry::ActiveDirectoryOU do
  let(:name) { "Team" }
  let(:domain) { 'example.com' }
  let(:instance) { FactoryGirl.build(:ec2_instance, team: FactoryGirl.build(:team, name: name), domain: domain) }
  subject { described_class.new(instance) }

  it "returns default ou" do
    expect(subject.ou).to eql("OU=Computers,DC=wonga,DC=aws")
  end

  context "when team has domain test.example.com" do
    let(:domain) { 'test.example.com' }

    it "uses team name in ou" do
      expect(subject.ou).to include("OU=#{name},")
    end

    context "when team name has whitespace on the beginning or end" do
      let(:name) { " Test " }
      it "escapes them" do
        expect(subject.ou).to include("OU=\\ Test\\ ,")
      end
    end

    context "when team name has # on the beginning" do
      let(:name) { "#Test" }
      it "escapes #" do
        expect(subject.ou).to include("OU=\\#{name}")
      end
    end

    context "when team has slash in name" do
      let(:name) { "Te,st" }

      it "escapes ," do
        expect(subject.ou).to include("OU=Te\\,st,")
      end
    end

    context "when team has slash in name" do
      let(:name) { "Te\\st" }

      it "escapes \\" do
        expect(subject.ou).to include("OU=Te\\\\st,")
      end
    end
  end
end
