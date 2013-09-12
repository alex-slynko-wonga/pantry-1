# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.

$ ->
  $("#ldap_users_search").autocomplete
    source: "/ldap_users",
    minLength: 4,
    select: ( event, ui ) ->
      if ui.item
        template = document.getElementById('user_template').innerHTML.
          replace(/%%name%%/g, ui.item.label).
          replace('%%username%%', ui.item.value)
        document.getElementById('users').innerHTML += template
        document.getElementById('users_list').value += ui.item.label + '\n'
      true

  $("i.icon-remove").on "click", (event) ->
    event.preventDefault()
    $(this).parents('.user').remove()
