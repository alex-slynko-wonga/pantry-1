require 'spec_helper'

describe WinRMRunner do
  let(:server) { double }
  before(:each) { EventMachine::WinRM::Session.stub(:new).and_return(server) }

  context "#add_host" do
    let(:host) { "some.host" }

    it "adds host with default user name and key" do
      expect(server).to receive(:use).with("ubuntu@#{host}", { keys: File.expand_path('~/.chef/aws-ssh-keypair.pem'), keys_only: true})
      subject.add_host(host)
    end

    it "adds host with set params" do
      expect(server).to receive(:use).with("user@host", { keys: 'key', keys_only: true })
      subject.add_host("host", "user", "key")
    end
  end

  context "#run_commands" do
    before(:each) do
      server.stub(:loop)
      server.stub(:close)
    end

    it "exec each command separately" do
      expect(server).to receive(:exec).twice
      subject.run_commands("test", "test")
    end
  end
end
