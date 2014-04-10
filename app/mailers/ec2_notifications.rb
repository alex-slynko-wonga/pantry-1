class Ec2Notifications < ActionMailer::Base
  helper ApplicationHelper

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.ec2_notifications.machine_created.subject
  #
  def machine_created(ec2_instance)
    subject = "Ec2 Instance has been created for you"
    @instance = ec2_instance
    @instance_kind = "Ec2 Instance"
    if ec2_instance.jenkins_server
      @instance_kind = "Jenkins"
      subject = "Jenkins has been created for you"
    elsif ec2_instance.jenkins_slave
      @instance_kind = "Slave for Jenkins"
      subject = "Slave has been created for your Jenkins"
    end
    mail to: ec2_instance.user.email, subject: subject
  end
end
