@Ec2InstanceCtrl = ["$scope", "$resource", ($scope, $resource) ->
  $scope.ec2_instance_id = $('div[data-ec2-instance-id]').data('ec2InstanceId')
  $scope.retryGetDetails = 2000
  $scope.policy = { start_instance: false, shutdown_now: false }

  getDetails = ->
    info = $resource('/ec2_instances/:ec2_instance_id.json').get({ec2_instance_id: $scope.ec2_instance_id }, ->
      $scope.ec2_instance = info
      $scope.policy = info.policies
      $scope.retryGetDetails = 2000
      if info.human_status == 'Ready'
        $scope.ec2_instance_instance_id = info.instance_id
        if !$scope.aws_status_timeout_id
          getAwsStatus()
          $scope.aws_status_timeout_id = setTimeout $scope.getDetails, $scope.retryGetDetails
      else
        clearTimeout $scope.aws_status_timeout_id
        $scope.aws_status_timeout_id = null
    , ->
      $scope.retryGetDetails = $scope.retryGetDetails * 2
    )
    setTimeout getDetails, $scope.retryGetDetails

  getAwsStatus = ->
    info = $resource('/ec2_instances/:ec2_instance_id/aws_status').get({ec2_instance_id: $scope.ec2_instance_instance_id }, ->
      $scope.ec2_instance_status = info
    )
    $scope.aws_status_timeout_id = setTimeout getAwsStatus, 300000

  getDetails()
]
