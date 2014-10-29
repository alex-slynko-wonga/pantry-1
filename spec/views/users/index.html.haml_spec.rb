require 'spec_helper'

RSpec.describe 'users/index', type: :view do
  let(:policy) { instance_double(UserPolicy, edit?: false) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  before(:each) do
    assign(:users, users)
    allow(view).to receive(:policy).and_return policy
  end

  describe 'if user is authorized to edit users' do
  end
end
