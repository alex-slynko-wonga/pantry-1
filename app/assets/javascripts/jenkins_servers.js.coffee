$(document).ready ->
  $("#index_jenkins_servers_team_id").change ->
    team_id = $("#index_jenkins_servers_team_id").val()
    $.get "/jenkins_servers?team_id=" + team_id, (data) ->
      document.write data