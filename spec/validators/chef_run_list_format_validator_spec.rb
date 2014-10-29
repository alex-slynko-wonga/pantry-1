require 'spec_helper'

class TestValidatorClass < OpenStruct
  include ActiveModel::Validations
end

RSpec.describe ChefRunListFormatValidator do
  before(:each) do
    TestValidatorClass.validates(:run_list, chef_run_list_format: true)
  end

  after(:each) do
    TestValidatorClass.clear_validators!
  end

  ['role[ test]', 'role[te_s-t]recipe[test]', 'recipe[test::]', "recipe[test']"].each do |name|
    it "disallows #{name}" do
      expect(TestValidatorClass.new(run_list: name)).to_not be_valid
    end
  end

  ['role[test]', 'role[te_s-t],role[test]', "role[te_s-t]\r\nrole[test]", 'role[te_s-t]', 'recipe[splunk]', 'recipe[te-s_t::splunk]'].each do |name|
    it "allows #{name}" do
      expect(TestValidatorClass.new(run_list: name)).to be_valid
    end
  end

  context 'without run_list' do
    it "doesn't raise exception" do
      TestValidatorClass.new.valid?
    end
  end
end
