require 'spec_helper'

describe Environment do
  let(:team) { FactoryGirl.create(:team) }

  it "is valid" do
    expect(FactoryGirl.build(:environment, name: 'env1')).to be_valid
  end

  it "allows only one CI environment_type per team" do
    FactoryGirl.create(:environment, team: team, environment_type: 'CI')
    expect(FactoryGirl.build(:environment, team: team, environment_type: 'CI')).to be_invalid
  end
end
