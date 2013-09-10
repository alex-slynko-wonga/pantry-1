require 'spec_helper'

describe Bill do
  subject { FactoryGirl.build(:bill) }
  it { should be_valid }
end
