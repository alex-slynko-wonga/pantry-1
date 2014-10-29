# rubocop:disable all
class UpadateEc2InstanceState < ActiveRecord::Migration
  def up
    Ec2Instance.all.each do |i|
      i.update_attributes(state: 'booted') if i.booted? && !i.bootstrapped && !i.joined
      i.update_attributes(state: 'joined') if i.booted && !i.bootstrapped && i.joined
      i.update_attributes!(state: 'ready') if i.booted && i.bootstrapped && i.joined
      i.update_attributes(state: 'terminating') if i.terminated_by_id
      i.update_attributes(state: 'terminated', terminated: true) if i.booted == false && i.bootstrapped == false && i.joined == false
    end
  end
end
# rubocop:enable all
