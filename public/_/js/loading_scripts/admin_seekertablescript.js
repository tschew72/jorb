
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

 function deleteUser(id, type)
    { 
      var r = confirm("WARNING: This action is irreversible. The User will be permanently removed from database! Are you sure?");
      if (r == true) {
        if (type == 1){
          $.post( "/delete_seeker", {userid: id}, function( data ) {
            confirm("Job Seeker account deleted!")
          });
        }
        if (type == 2){
          $.post( "/delete_coyuser", {userid: id}, function( data ) {
            confirm("Recruiter account deleted!")
          });
        }
      } else {
          
      }
      return false; 
    };