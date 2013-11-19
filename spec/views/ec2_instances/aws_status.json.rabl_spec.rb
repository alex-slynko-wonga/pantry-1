require 'spec_helper'

describe "ec2_instances/aws_status" do
  it "returns cpu_utilization and status_check_failed" do
    cpu_utilization = '42'
    status_check_failed = '0'
    assign(:ec2_instance_status, Ec2InstanceStatus.new(cpu_utilization, status_check_failed))
    render
    parsed_response = JSON.parse(response)
    expect(parsed_response['cpu_utilization']).to eq(cpu_utilization)
    expect(parsed_response['status_check_failed']).to eq(status_check_failed)
  end
end
