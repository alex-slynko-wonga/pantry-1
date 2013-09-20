require "spec_helper"

describe Ec2Notifications do
  describe "machine_created" do
    let(:mail) { Ec2Notifications.machine_created(instance) }

    before(:each) do
      instance.id = 42
    end

    context "for regular instance" do
      let(:instance) { FactoryGirl.build(:ec2_instance) }

      it "renders the headers" do
        expect(mail.subject).to eq("Ec2 Instance has been created for you")
        expect(mail.to).to include(instance.user.email)
      end

      it "renders the body" do
        expect(mail.body.encoded).to match(instance.id.to_s)
      end
    end

    context "for Jenkins Server instance" do
      let(:instance) { FactoryGirl.build(:jenkins_server).ec2_instance }

      it "renders the headers" do
        expect(mail.subject).to eq("Jenkins has been created for you")
        expect(mail.to).to include(instance.user.email)
      end

      it "renders the body" do
        expect(mail.body.encoded).to match(instance.id.to_s)
      end
    end

    context "for Slave instance" do
      let(:slave) { FactoryGirl.build(:jenkins_slave) }
      let(:instance) { slave.ec2_instance }

      it "renders the headers" do
        expect(mail.subject).to eq("Slave has been created for your Jenkins")
        expect(mail.to).to include(instance.user.email)
      end


      it "renders the body" do
        expect(mail.body.encoded).to match(instance.id.to_s)
      end
    end
  end
end
