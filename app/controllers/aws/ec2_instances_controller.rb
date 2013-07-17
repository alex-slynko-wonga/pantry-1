class Aws::Ec2InstancesController < ApplicationController
  def new
    @ec2_instance = Ec2Instance.new
    fog = Fog::Compute.new(provider: 'AWS')
    amis = fog.describe_images("Owner" => "self").body["imagesSet"]
    @ami_options = amis.each_with_object({}) do |ami, ami_options|
      ami_options[ami["name"]] = ami["imageId"]
    end
    @flavor_options = {
      't1.micro' => 't1.micro'
    }
  end

  def create
    ec2_instance = Ec2Instance.new(
      ec2_instance_params.merge({user_id: current_user.id})
    )
    if ec2_instance.save
      msg = {
          pantry_request_id:  ec2_instance.id,
          instance_name:      params["ec2_instance"][:name],
          flavor:             params["ec2_instance"][:flavor],
          ami:                params["ec2_instance"][:ami],
          team:               params["ec2_instance"][:team],
          subnet_id:          params["ec2_instance"][:subnet_id],
          security_group_ids: params["ec2_instance"][:security_group_ids]
      }.to_json
      sqs = AWS::SQS::Client.new()
      queue_url = sqs.get_queue_url(queue_name: "boot_ec2_instance")[:queue_url]
      puts "QUEUE #{queue_url}"
      if !queue_url.nil?
        sqs.send_message(queue_url: queue_url, message_body: msg)
      end

      #Delayed::Job.enqueue EC2Runner.new(
      #  ec2_instance.id,
      #  params["ec2_instance"][:name],
      #  params["ec2_instance"][:flavor],
      #  params["ec2_instance"][:ami],
      #  params["ec2_instance"][:team],
      #  params["ec2_instance"][:subnet_id],
      #  params["ec2_instance"][:security_group_ids]
      #)
      redirect_to "/aws/ec2s/"
    else
      render :new
    end
  end

  def show
    @ec2_instance = Ec2Instance.find params[:id]
  end

  private

  def ec2_instance_params
    params.require(:ec2_instance).permit(:name, :team_id, :user_id, :ami, :flavor)
  end
end

