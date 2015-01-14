
  $('#coyusertable').dataTable( {   //need to include the Ajax source so that I can reload it from anywhere
      "scrollY": 200,
      "ScrollX": true,
      "iDisplayLength": 10,
      "order": [[ 0, "desc" ]],
      "scrollCollapse": true,
      "jQueryUI": true,
      "aoColumns": [         
          null, 
          null, 
          null,
          { "bSortable": false },
          { "bSortable": false }
        ],
      "columns": [
        null,
        null,
        null,
        { "width": "20%" },
        { "width": "20%" }
      ]
  } );


  $('.c_accesslevel').editable({
    source: [
              {value: 1, text: 'Admin Rights'},
              {value: 2, text: 'Job Posting Rights'},
           ],
    emptytext: '--',
    validate: function(value){
      if (!value) return 'This field is required';
      }, //function
    url: "/updateaccesslevel",
    showbuttons: false

  });


    $('.status').editable({
    source: [
              {value: 0, text: 'Inactive'},
              {value: 1, text: 'Active'},
           ],
    emptytext: '--',
    validate: function(value){
      if (!value) return 'This field is required';
      }, //function
    url: "/updatestatus",
    showbuttons: false



  });