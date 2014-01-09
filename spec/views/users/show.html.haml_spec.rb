require 'spec_helper'

describe "users/show" do
  let(:policy) { instance_double(UserPolicy, edit?: false) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  before(:each) do
    assign(:user, user)
    allow(view).to receive(:policy).and_return policy
  end

  describe "if user not authorized enough" do
    it "not renders the edit action" do
      render
      expect(rendered).not_to match 'Edit'
    end
  end

  describe "if user is authorized to edit users" do
    let(:policy) { instance_double(UserPolicy, edit?: true) }

    it "renders the edit action" do
      render
      expect(rendered).to match 'Edit'
    end
  end
end


