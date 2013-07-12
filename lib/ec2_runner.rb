require 'timeout'
class EC2Runner < Struct.new(:pantry_request_id,:instance_name,:flavor,:ami,:team)

  def  perform
    
      aws = Fog::Compute.new(:provider=>'AWS')
      
      ec2_inst = aws.servers.create(:image_id => ami,:flavor_id => flavor)
      
      aws.tags.create(
        :resource_id => ec2_inst.identity,
        :key => 'Name',
        :value => instance_name
      )
      
     aws.tags.create(
        :resource_id => ec2_inst.identity,
        :key => 'team',
        :value => team
      )
      
      aws.tags.create(
        :resource_id => ec2_inst.identity,
        :key => 'pantry_request_id',
        :value => pantry_request_id
      )
  
      ec2_inst .wait_for { print "#{ec2_inst.state}#."; ready? }
      print ec2_inst.id
      status = Timeout::timeout(300){
        while true do 
          # Valid values: ok | impaired | initializing | insufficient-data | not-applicable
          instance_status = aws.describe_instance_status('InstanceId'=>ec2_inst.id).body["instanceStatusSet"][0]["instanceStatus"]["status"]
          print "."
          print instance_status
  
          case instance_status
            when "ok"
              #ec2_instance.start!(:boot, ec2_inst.id)
              return  ec2_inst.id
            when "impaired"
              raise "impaired"
            when "insufficient-data"
              raise "insufficient-data"
            when "not-applicable"
              raise "not-applicable"
          end
        end
      }
      rescue
        #ec2_instance.start!(:boot, nil)
        return  nil
    end
  end
  