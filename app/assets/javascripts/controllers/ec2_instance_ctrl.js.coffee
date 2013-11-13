@Ec2InstanceCtrl = ["$scope", "$resource", ($scope, $resource) ->
  $scope.getAwsStatus = ->
    $scope.ec2_instance_id = $('div[data-instance-id]').data('instance-id')
    info = $resource('/ec2_instances/:ec2_instance_id/aws_status').get({ec2_instance_id: $scope.ec2_instance_id }, ->
      $scope.ec2_instance_status = info
    )
]
