Ec2InstanceStatus = Struct.new(:cpu_utilization, :status_check_failed) do
  def self.find(instance_id)
    metrics = AWS::CloudWatch.new.metrics.with_dimensions({name: 'InstanceId', value: instance_id}).to_a
    utilization = load_statistics(metrics.detect { |metric| metric.metric_name == 'CPUUtilization' })
    status_check_failed  = load_statistics(metrics.detect { |metric| metric.metric_name == 'StatusCheckFailed' })
    new(utilization, status_check_failed)
  end

  private
  def self.load_statistics(metric)
    return "N/A" unless metric
    statistics = metric.statistics(start_time: Time.current - 600, end_time: Time.current, statistics: ['Average'])
    last_point = statistics.datapoints.max_by { |point| point[:timestamp] }
    last_point[:average]
  end
end
