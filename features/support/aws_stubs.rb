def stub_security_groups
  client = AWS::EC2.new.client
  security_groups = client.new_stub_for(:describe_security_groups)

  security_groups[:security_group_info] = [
    { group_name: "#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455", group_id: '1' },
    { group_name: "#{CONFIG['pantry']['security_groups_prefix']}WebServer-001122334455", group_id: '2' },
    { group_name: "#{CONFIG['pantry']['security_groups_prefix']}GraphiteServer-001122334455", group_id: '3' },
    { group_name: "#{CONFIG['pantry']['security_groups_prefix']}JavaServer-001122334455", group_id: '4' },
    { group_name: "#{CONFIG['pantry']['security_groups_prefix']}PHPServer-001122334455", group_id: '5' }
  ]
  allow(client).to receive(:describe_security_groups).and_return(security_groups)
end

def stub_subnets
  client = AWS::EC2.new.client
  subnets = client.new_stub_for(:describe_subnets)
  subnets[:subnet_set] = [{ subnet_id: '42' }]
  allow(client).to receive(:describe_subnets).and_return(subnets)
end

def stub_ami_info(ami_id = 'i-121111', name = 'image_name')
  client = AWS::EC2.new.client
  amis = client.new_stub_for(:describe_images)
  amis[:images_set] = [{ name: name, image_id: ami_id }]
  amis[:image_index] = { ami_id => { platform: 'windows' } }
  allow(client).to receive(:describe_images).and_return(amis)
end

def stub_sns
  sns_client = AWS::SNS.new.client
  sns_client.stub(:publish).and_return(AWS::Core::Response.new)
end

def stub_sqs
  sqs_client = AWS::SQS.new.client
  resp = sqs_client.stub_for(:get_queue_url)
  resp[:queue_url] = 'https://some_url.example.com'
  sqs_client.stub(:send_message).and_return(AWS::Core::Response.new)
end
