
  $('#admin_coytable').dataTable( {  
      "scrollY": 200,
      "ScrollX": true,
      "iDisplayLength": 5,
      "bAutoWidth": false,
      "order": [[ 0, "desc" ]],
      "scrollCollapse": true,
      "jQueryUI": true,
      "aoColumns": [         
          null, 
          null, 
          null,
          null,
         { "bSortable": false },{ "bSortable": false }
        ]
  } );

$('#coyTable').editable({
  selector: 'a.coy_suspended',
  showbuttons: false
}); //company_suspended


