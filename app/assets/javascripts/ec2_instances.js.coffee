$(document).ready ->
  $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").click ->
    bol = $("input[type=checkbox][name='ec2_instance[security_group_ids][]']:checked").length >= 4
    $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").not(":checked").attr("disabled", bol)

  $("select[id=ec2_instance_environment_id]").click ->
    team_name = $(this.options[this.selectedIndex]).closest('optgroup').prop('label')
    if team_name
        $("label[for=ec2_instance_team_name]").text('Team: ' + team_name)