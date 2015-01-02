$(document).ready ->
  updateSecurityGroups()

  $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").click ->
    updateSecurityGroups()

  $("select[id=ec2_instance_environment_id]").change ->
    team_name = $(this.options[this.selectedIndex]).closest('optgroup').prop('label')
    if team_name
      $("label[for=ec2_instance_team_name]").text('Team: ' + team_name)

    if $("#ec2_instance_instance_role_id option:selected").text()
      $('.instance_role_subvalue').hide()

  $("select[id=ec2_instance_instance_role_id]").change ->
    if this.selectedIndex
      $('.instance_role_subvalue').hide()
    else
      $('.instance_role_subvalue').show()

  $("select[id=ec2_instance_flavor]").change ->
    updateFlavor this

  $("select[id=instance_role_instance_size]").change ->
    updateFlavor this

  updateFlavor = (flavor) ->
    flavor_data = $(flavor.options[flavor.selectedIndex])
    if flavor.selectedIndex and (flavor_data.data('windows-price') or flavor_data.data('linux-price'))
      $(".instance_flavor_details").show()
      $(".instance_flavor_details .price_per_hour_windows").text(flavor_data.data('windows-price'))
      $(".instance_flavor_details .price_per_hour_linux").text(flavor_data.data('linux-price'))
      $(".instance_flavor_details .virtual_cores").text(flavor_data.data('cores'))
      $(".instance_flavor_details .ram").text(flavor_data.data('ram'))
    else
      $(".instance_flavor_details").hide()

updateSecurityGroups = ->
  bol = $("input[type=checkbox][name='ec2_instance[security_group_ids][]']:checked").length >= 4
  $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").not(":checked").attr("disabled", bol)
