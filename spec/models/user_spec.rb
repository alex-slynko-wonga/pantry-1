require 'spec_helper'

describe User do
  let(:user_id) { 'some_user_id' }
  let(:user_email) { 'test@example.com' }

  describe ".from_omniauth" do
    let(:group) { "CN=Group,OU=Users,DC=example,DC=com" }

    before(:each) do
      config =  Marshal.load(Marshal.dump(CONFIG))
      config['omniauth'].merge!('ldap_group' => group)
      stub_const('CONFIG', config)
    end

    context "when user is not in required LDAP group" do
      let(:omniauth_params) { {'samaccountname' => [user_id], 'email' => [user_email], 'displayname' => ['name'], 'memberof' => []} }

      it "does nothing" do
        expect(User.from_omniauth(omniauth_params)).to be_nil
      end
    end

    context "when user is in required LDAP group" do
      let(:omniauth_params) { { 'samaccountname' => [user_id], 'email' => [user_email], 'displayname' => ['name'], 'memberof' => [group] } }
      context "if user doesn't exist" do
        it "creates user with id and email" do
          user = nil
          expect { user = User.from_omniauth(omniauth_params) }.to change { User.count }.by(1)
          expect(user.username).to eq(user_id)
        end
      end

      context "if user exists" do
        let!(:user) { FactoryGirl.create(:user, username: user_id) }

        it "returns existing user" do
          expect(User.from_omniauth(omniauth_params)).to eq(user)
        end
      end
    end
  end

  describe "#email" do
    context "when user has entered email" do
      subject { User.new(email: user_email) }

      describe '#email' do
        subject { super().email }
        it { should == user_email }
      end
    end

    context "when user hasn't entered email" do
      subject { User.new(username: user_id) }

      it "should be generated from user_name" do
        expect(subject.email).to eq("#{user_id}@example.com")
      end
    end

    it "returns lowercase email" do
      expect(User.new(email: 'Test@example.com').email).to eq('test@example.com')
    end
  end

  describe "#have_billing_access?" do
    let(:user) { User.new(email: email) }
    subject { user.have_billing_access? }
    let(:email) { 'test@example.com' }

    context "for jonathan" do
      let(:email) { 'jonathan.galore@example.com' }
      it { should be_truthy }
    end

    context "for user who allowed in config" do
      before(:each) do
        stub_const('CONFIG', { 'billing_users' => 'test@example.com' })
      end

      it { should be_truthy }
    end

    context "for any other user" do
      it { should be_falsey }
    end
  end

  describe "member_of_team?" do
    it "returns true if the user is member of the given team" do
      user = FactoryGirl.create(:user)
      team = FactoryGirl.create(:team, users: [user])
      expect(user.member_of_team?(team)).to be_truthy
    end

    it "returns false if the user is not a member of the given team" do
      user = FactoryGirl.create(:user)
      team = FactoryGirl.create(:team, users: [])
      expect(user.member_of_team?(team)).to be_falsey
    end
  end
end
