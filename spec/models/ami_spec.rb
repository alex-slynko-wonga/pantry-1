require 'spec_helper'

describe Ami do
  subject { FactoryGirl.build(:ami) }

  it { should be_valid }
end
