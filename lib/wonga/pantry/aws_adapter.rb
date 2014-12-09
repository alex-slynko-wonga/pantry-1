class Wonga::Pantry::AWSAdapter
  def iam_role_list
    iam_client.list_roles.roles
  end

  private

  def iam_client
    @iam_client ||= AWS::IAM.new.client
  end
end
