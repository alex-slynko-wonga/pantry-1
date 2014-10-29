require 'spec_helper'

RSpec.describe UserPolicy do
  permission :edit?, :see_queues?, :admin? do
    context 'for superadmin' do
      subject { UserPolicy.new(User.new(role: 'superadmin'), User.new) }

      it { is_expected.to permit }
    end
  end
end
