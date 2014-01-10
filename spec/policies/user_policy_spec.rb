require 'spec_helper'

describe UserPolicy do
  permission :edit? do
    context "for superadmin" do
      subject { UserPolicy.new(User.new(role: 'superadmin'), User.new) }

      it { should permit }
    end
  end
end

