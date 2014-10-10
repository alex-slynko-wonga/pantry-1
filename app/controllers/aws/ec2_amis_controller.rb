class Aws::Ec2AmisController < ApplicationController
  def show
    id = params[:id]
    id = Ami.find(id).ami_id if params[:use_pantry_id]
    ami = Wonga::Pantry::Ec2Adapter.new(pundit_user).get_ami_attributes(id)

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
