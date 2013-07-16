# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
@Ec2InstanceRequestStatusPoller =
  poll: ->
    setTimeout @request, 2000
    
  request: ->
    $.get $('#ec2instance_status').data('url'), (data) ->
      $("#ec2instance_status_content").html data
    
$ ->
  if $('#ec2instance_status').length > 0
    Ec2InstanceRequestStatusPoller.poll()