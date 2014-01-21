require 'spec_helper'

describe Environment do
  it "is valid" do
    expect(FactoryGirl.build(:environment, name: 'env1')).to be_valid
  end
end
