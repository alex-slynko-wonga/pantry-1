class CreateAmisFromAws < ActiveRecord::Migration
  def up
    AWS::EC2.new.images.with_owner('self').to_a.map do |image|
      { platform: image.platform || 'linux', ami_id: image.id, name: image.name }
    end.each { |params| Ami.create!(params) }
  end

  def down
    Ami.destroy_all
  end
end
