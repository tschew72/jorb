
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
          null,
         { "bSortable": false },{ "bSortable": false },{ "bSortable": false }
        ]
  } );

function deleteUser(id)
  { 
    var r = confirm("WARNING: This action is irreversible. The User will be permanently removed from database! Are you sure?");
    if (r == true) {
        $.post( "/delete_user", {userid: id}, function( data ) {
          confirm("User account deleted!")
          $("#seekerTable").load("/admin_seekertable",{i: new Date().getTime()}, function(){
            $.getScript("_/js/loading_scripts/admin_seekertablescript.js");
            window.location.hash = '#aa';
            window.location.hash = '#seekerTable';
          });
        });
    } else {
        
    }
    return false; 
  };