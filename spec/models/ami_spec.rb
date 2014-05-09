require 'spec_helper'

describe Ami do
  it "should be valid" do
    expect(FactoryGirl.build(:ami)).to be_valid
  end
end
