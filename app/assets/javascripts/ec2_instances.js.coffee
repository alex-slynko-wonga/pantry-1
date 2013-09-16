$(document).ready ->
  $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").click ->
    bol = $("input[type=checkbox][name='ec2_instance[security_group_ids][]']:checked").length >= 4
    $("input[type=checkbox][name='ec2_instance[security_group_ids][]']").not(":checked").attr("disabled", bol)