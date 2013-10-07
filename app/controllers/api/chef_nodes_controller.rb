class Api::ChefNodesController < ApiController
  def destroy
    ec2_instance = Ec2Instance.find(params[:id])
    ec2_instance.chef_node_delete
    respond_with {}
  end
end
