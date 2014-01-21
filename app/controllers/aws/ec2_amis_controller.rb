class Aws::Ec2AmisController < ApplicationController
  before_filter :initialize_ec2_adapter, only: [:show]

  def show
    @ami = @ec2_adapter.get_ami_attributes(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @ami }
    end
  end

  private

  def initialize_ec2_adapter
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new
  end
end

