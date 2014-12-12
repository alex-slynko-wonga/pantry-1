namespace :update_from_aws do
  desc 'Update all Ec2Instance records from AWS'
  task all: :environment do
    results = Wonga::Pantry::Ec2InstancesUpdater.new.update_from_aws
    puts "Updated:#{results['updated'].each { |id| print ' ', id }}"
    puts "Errors:#{results['errors'].each { |id| print ' ', id }}"
    puts "Untagged:#{results['untagged'].each { |id| print ' ', id }}"
  end

  desc 'Update a single Ec2Instance record from AWS'
  task :instance, [:id] => :environment do |_t, args|
    instance = Ec2Instance.find(args.id)
    case instance.update_info
    when true
      puts "Ec2Instance #{instance.id} is updated"
    when nil
      puts "Ec2Instance #{instance.id} is unchanged"
    else
      puts "Ec2Instance #{instance.id} had error updating"
    end
  end
end
