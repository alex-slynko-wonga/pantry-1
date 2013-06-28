require 'spec_helper'

describe User do
  let(:user_id) { 'some_user_id' }
  let(:user_email) { 'test@example.com' }
  let(:omniauth_params) { {'samaccountname' => [user_id], 'email' => [user_email], 'displayname' => ['name']} }

  describe ".from_omniauth" do
    context "if user doesn't exist" do
      it "creates user with id and email" do
        user = nil
        expect { user = User.from_omniauth(omniauth_params) }.to change { User.count }.by(1)
        expect(user.username).to eq(user_id)
      end
    end

    context "if user exists" do
      let!(:user) { FactoryGirl.create(:user, username: user_id) }

      it "returns existsing user" do
        expect(User.from_omniauth(omniauth_params)).to eq(user)
      end
    end
  end

  describe "#email" do
    context "when user has entered email" do
      subject { User.new(email: user_email) }
      its(:email) { should == user_email }
    end

    context "when user hasn't entered email" do
      subject { User.new(username: user_id) }

      its(:email) { should == "#{user_id}@example.com" }
    end
  end
end
