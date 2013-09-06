require 'spec_helper'

describe Wonga::Pantry::ActiveDirectoryOU do
  let(:name) { "team" }
  let(:domain) { 'example.com' }
  let(:instance) { FactoryGirl.build(:ec2_instance, team: FactoryGirl.build(:team, name: name), domain: domain) }
  subject { described_class.new(instance) }

  it "returns default ou" do
    expect(subject.ou).to eql(CONFIG['pantry']['default_ou'])
  end

  context "when team has domain test.#{CONFIG['pantry']['domain']}" do
    let(:domain) { "test.#{CONFIG['pantry']['domain']}" }

    it "uses team name in ou" do
      expect(subject.ou).to include("OU=#{name},")
    end

    context "when team name has restricted symbols" do
      let(:name) { 'test test -,.#test  , ' }

      it "uses sanitized name" do
        expect(subject.ou).to include("OU=test-test-test,OU")
      end
    end

    context "when team name is too long" do
      let(:name) { 'a'*64 + 'b' }

      it "shortens it" do
        expect(subject.ou).to include("aaaa,OU")
      end
    end
  end
end
