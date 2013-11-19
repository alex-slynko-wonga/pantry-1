require 'spec_helper'

describe Ec2InstanceStatus do
  describe ".find" do
    it "loads information from CloudWatch" do
      metrics = AWS::CloudWatch.new.client.stub_for(:list_metrics)
      metrics[:metrics] = [{metric_name: 'CPUUtilization', namespace: 'Test'},{metric_name: 'StatusCheckFailed', namespace: 'Test'}]
      statistics = AWS::CloudWatch.new.client.stub_for :get_metric_statistics
      statistics[:datapoints] =  [{timestamp: Time.current, unit: 'Percent', average: 2 }]
      status = Ec2InstanceStatus.find('42')
      expect(status.cpu_utilization).to eq(2)
      expect(status.status_check_failed).to eq(2)
      metrics[:metrics].clear
      statistics[:datapoints].clear
    end

    it "should return N/A when CloudWatch unavailable" do
      status = Ec2InstanceStatus.find('42')
      expect(status.cpu_utilization).to eq('N/A')
      expect(status.status_check_failed).to eq('N/A')
    end
  end
end
