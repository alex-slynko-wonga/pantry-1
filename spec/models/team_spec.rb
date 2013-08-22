require 'spec_helper'

describe Team do
  subject { FactoryGirl.build(:team) }
  it { should be_valid }
end
