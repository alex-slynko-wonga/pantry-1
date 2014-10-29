class AwsCostsController < ApplicationController
  def show
    authorize(Ec2InstanceCost)
    key = "#{params[:id]}.#{params[:format]}"
    begin
      csv = s3.get_object(bucket_name: CONFIG['aws']['billing_bucket'], key: key)[:data]
      send_data csv, filename: key, disposition: 'attachment'
    rescue AWS::S3::Errors::NoSuchKey
      redirect_to '/aws_costs/'
    end
  end

  def index
    authorize(Ec2InstanceCost)
    @csv_keys = s3.list_objects(bucket_name: CONFIG['aws']['billing_bucket'])[:contents].map do|i|
      i[:key]
    end
  end

  private

  def s3
    AWS::S3::Client.new
  end
end
