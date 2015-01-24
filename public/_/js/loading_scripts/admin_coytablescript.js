
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



  function deleteCoy(i){
    var r = confirm("WARNING: This action is irreversible. The Company will be permanently removed from database! Are you sure?");
    if (r == true) {
        $.post( "/delete_coy", {coyid: i}, function( data ) {
          confirm("Company deleted!")
          $("#coyTable").load("/admin_coytable",{i: new Date().getTime()}, function(){
            $.getScript("_/js/loading_scripts/admin_coytablescript.js"); 
          }); 
        });
    } else {
        
    }
    return false; 

  }//delcoyuser