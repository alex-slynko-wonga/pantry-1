@Ec2InstanceRequestStatusPoller =
  poll: ->
    setTimeout @request, 2000

  request: ->
    $.get $('#ec2instance_status').data('url'), (data) ->
      $("#ec2instance_status_content").html data
