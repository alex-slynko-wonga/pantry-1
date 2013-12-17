require 'spec_helper'

describe LdapResource do
  let(:ldap) { instance_double('Net::LDAP') }
  let(:filter) { instance_double('Net::LDAP::Filter') }
  let(:default_filter) { instance_double('Net::LDAP::Filter') }
  let(:or_filter) { double(:| => filter) }
  let(:record) { double }
  let(:username) { 'user_id' }
  let(:group) { "CN=Group,OU=Users,DC=example,DC=com" }

  before(:each) do
    config =  Marshal.load(Marshal.dump(CONFIG))
    config['omniauth'].merge!(ldap_group: group)
    stub_const('CONFIG', config)
    Net::LDAP.stub(:new).and_return(ldap)
    Net::LDAP::Filter.stub(:eq).with('memberOf', group).and_return(default_filter)
    default_filter.stub(:&).with(filter).and_return(filter)
  end

  it "filters by default group" do
    subject
    expect(Net::LDAP::Filter).to have_received(:eq).with('memberOf', group)
  end

  context "#filter_by_group" do
    it "searches using Net::LDAP" do
      expect(ldap).to receive(:search).with(filter: filter).and_return([record])
      expect(Net::LDAP::Filter).to receive(:eq).with('memberOf', 'group').and_return(filter)
      expect(subject.filter_by_group('group').all).to eql [record]
    end
  end

  context "#filter_by_name" do

    before(:each) do
      expect(Net::LDAP::Filter).to receive(:eq).with('sAMAccountName', username).and_return(or_filter)
      expect(Net::LDAP::Filter).to receive(:eq).with('DisplayName', username).and_return(or_filter)
    end

    it "searches using Net::LDAP" do
      expect(ldap).to receive(:search).with(filter: filter).and_return([record])
      expect(subject.filter_by_name(username).all).to eql [record]
    end

    it "returns empty array if record not found" do
      expect(ldap).to receive(:search).with(filter: filter).and_return(false)
      expect(subject.filter_by_name(username).all).to be_empty
    end
  end

  context "filter with several filters" do
    before(:each) do
      default_filter.stub(:&).with(default_filter).and_return(default_filter)
      expect(Net::LDAP::Filter).to receive(:eq).with('memberOf', 'group').and_return(default_filter)
      expect(Net::LDAP::Filter).to receive(:eq).with('sAMAccountName', username).and_return(or_filter)
      expect(Net::LDAP::Filter).to receive(:eq).with('DisplayName', username).and_return(or_filter)
    end

    it "searches using Net::LDAP" do
      subject.filter_by_group('group').filter_by_name(username)
      expect(ldap).to receive(:search).with(filter: filter).and_return([record])
      expect(subject.all).to eql [record]
    end
  end
end
