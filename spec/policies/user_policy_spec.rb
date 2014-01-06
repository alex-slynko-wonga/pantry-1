require 'spec_helper'

describe UserPolicy do
  context "for superadmin" do
    subject { UserPolicy.new(User.new(role: 'superadmin'), User.new) }

    it { should permit(:edit?) }
  end
end

