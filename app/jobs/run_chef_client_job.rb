require 'chef_node_resource'

RunChefClientJob = Struct.new(:job_id, :command) do
  def perform
    job = Job.find job_id
    package = job.package
    environment, role = package.bag_title, package.item_title
    job.start!

    nodes = ChefNodeResource.list_nodes(environment, "wonga_#{role}").group_by do |node|
      node['os']
    end

    @job_logs = nodes.values.flatten.each_with_object({}) do |node, logs|
      logs[node.name] = JobLog.create(job_id: job_id, machine: node.name, log_text: "Initiated: #{Time.now}\n" )
    end

    if nodes['windows']
      runner_windows = WinRMRunner.new
      nodes['windows'].each do |node|
        runner_windows.add_host(node.name)
      end
      runner_windows.run_commands command do |host, log|
        update_log(host, log)
      end
    end

    if nodes['linux']
      runner_linux = SshRunner.new
      nodes['linux'].each do |node|
        runner_linux.add_host(node.name)
      end
      runner_linux.run_commands command do |host, log|
        update_log(host, log)
      end
    end
    job.complete!
  rescue
    @job_logs.values.each { |log| log.update_log($!.to_s) }
    @job_logs.values.each { |log| log.update_log($!.backtrace.to_s) }

    raise $!
  end

  def update_log(name, text)
    @job_logs[name].update_log(text)
  end
end
