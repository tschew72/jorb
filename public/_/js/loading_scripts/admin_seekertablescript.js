
  $('#admin_seekertable').dataTable( {  
      "scrollY": 200,
      "ScrollX": true,
      "iDisplayLength": 5,
      "order": [[ 0, "desc" ]],
      "bAutoWidth": false,
      "scrollCollapse": true,
      "jQueryUI": true,
      "aoColumns": [         
          null, 
          null, 
          null,
          null,
         { "bSortable": false },{ "bSortable": false },{ "bSortable": false }
        ]
  } );
