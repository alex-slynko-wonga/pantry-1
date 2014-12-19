$ ->
  $('table.sortable-datatable-full').dataTable
    paging: true
    info: true
    searching: true
  $('table.sortable-datatable-short').dataTable
    paging: false
    info: false
    searching: false