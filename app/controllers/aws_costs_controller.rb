class AwsCostsController < ApplicationController
  before_filter :check_rights

  def show
    key = "#{params[:id]}.#{params[:format]}"
    begin
      csv = s3.get_object(bucket_name: CONFIG["aws"]["billing_bucket"], key: key)[:data]
      send_data csv, filename: key, disposition: 'attachment'
    rescue AWS::S3::Errors::NoSuchKey
      redirect_to "/aws_costs/"
    end
  end

  def index
    @csv_keys = s3.list_objects(bucket_name: CONFIG["aws"]["billing_bucket"])[:contents].map {|i|
      i[:key]
    }
  end

  private
  def s3
    AWS::S3::Client.new
  end

  def check_rights
    redirect_to root_url unless current_user.email == 'jonathan.galore@example.com'
  end
end
