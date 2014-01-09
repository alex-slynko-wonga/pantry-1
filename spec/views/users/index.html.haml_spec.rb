require 'spec_helper'

describe "users/index" do
  let(:policy) { instance_double(UserPolicy, edit?: false) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  before(:each) do
    assign(:users, users)
    allow(view).to receive(:policy).and_return policy
  end

  describe "if user is authorized to edit users" do
  end
end

