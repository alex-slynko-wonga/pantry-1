class Aws::Ec2AmisController < ApplicationController
  def show
    ami = Wonga::Pantry::Ec2Adapter.new(current_user).get_ami_attributes(params[:id])

    respond_to do |format|
      format.json do
        if ami.present?
          render json: ami
        else
          render status: :not_found, json: {}
        end
      end
    end
  end
end
