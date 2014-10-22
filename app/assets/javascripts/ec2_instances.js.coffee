$(document).ready ->
  $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").click ->
    bol = $("input[type=checkbox][name='ec2_instance[security_group_ids][]']:checked").length >= 4
    $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").not(":checked").attr("disabled", bol)

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