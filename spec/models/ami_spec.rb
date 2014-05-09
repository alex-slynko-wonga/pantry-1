require 'spec_helper'

describe Ami do
  it { expect(FactoryGirl.build(:ami)).to be_valid }
end
