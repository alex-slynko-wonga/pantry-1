class Api::Ec2InstancesController < ApiController
  def update
    user = User.where(id: params[:user_id]).first || nil
    Wonga::Pantry::Ec2InstanceState.new(Ec2Instance.find(params[:id]), user, params).change_state!
    respond_with {}
  end

  def update_from_aws
    results = { 'aws_tagged' => [], 'errors' => [], 'unchanged' => [], 'untagged' => [], 'updated' => []}
    AWS::EC2.new.instances.each do |aws_instance|
      if aws_instance.tags['pantry_request_id']
        ec2_instance = Ec2Instance.find(aws_instance.tags['pantry_request_id'])
        case ec2_instance.update_info(aws_instance)
        when true
          results['updated'] << ec2_instance.id
        when nil
          results['unchanged'] << ec2_instance.id
        else
          results['errors'] << ec2_instance.id
        end
      elsif has_aws_tags?(aws_instance)
        results['aws_tagged'] << aws_instance.instance_id
      else
        results['untagged'] << aws_instance.instance_id
        logger.error("Found untagged instance #{aws_instance.instance_id}")
      end
      logger.info("Updated records from AWS: Errors #{results['errors'].count.to_s}, Unchanged #{results['unchanged'].count.to_s}, Untagged #{results['untagged'].count.to_s}, Updated #{results['updated'].count.to_s}")
    end
    render json: results
  end

  private
  def has_aws_tags?(aws_instance)
    cf_tags = [
      'aws:cloudformation:logical-id',
      'aws:cloudformation:stack-id',
      'aws:cloudformation:stack-name',
      'aws:autoscaling:groupName'
    ]
    aws_instance.tags.to_h.any? { |k,v| cf_tags.include?(k) }
  end
end
