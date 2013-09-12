require 'spec_helper'

describe LdapResource do
  let(:ldap) { double }
  let(:filter) { double }
  let(:record) { double }
  let(:username) { 'user_id' }

  before(:each) do
    Net::LDAP.stub(:new).and_return(ldap)
  end

  context "#find_user_by_display_name" do
    it "searches using Net::LDAP" do
      expect(ldap).to receive(:search).with(filter: filter).and_return([record])
      expect(Net::LDAP::Filter).to receive(:eq).with('DisplayName', username).and_return(filter)
      expect(subject.find_user_by_display_name(username)).to eql [record]
    end
  end

  context "#all_users_from_group" do
    it "searches using Net::LDAP" do
      expect(ldap).to receive(:search).with(filter: filter).and_return([record])
      expect(Net::LDAP::Filter).to receive(:eq).with('memberOf', 'group').and_return(filter)
      expect(subject.all_users_from_group('group')).to eql [record]
    end
  end

  context "#find_user_by_name" do
    let(:or_filter) { double(:| => filter) }

    before(:each) do
      expect(Net::LDAP::Filter).to receive(:eq).with('sAMAccountName', username).and_return(or_filter)
      expect(Net::LDAP::Filter).to receive(:eq).with('DisplayName', username).and_return(filter)
    end

    it "searches using Net::LDAP" do
      expect(ldap).to receive(:search).with(filter: filter).and_return([record])
      expect(subject.find_user_by_name(username)).to eql [record]
    end

    it "returns nil if record not found" do
      expect(ldap).to receive(:search).with(filter: filter).and_return(false)
      expect(subject.find_user_by_name(username)).to be_empty
    end
  end
end
