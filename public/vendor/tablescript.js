        $('#skillsettingtable').dataTable( {   //need to include the Ajax source so that I can reload it from anywhere
            "scrollY": 200,
            "ScrollX": true,
            "iDisplayLength": 10,
            "order": [[ 0, "desc" ]],
            "scrollCollapse": true,
            "jQueryUI": true,
            "aoColumns": [         
                null, null, null,
                { "bSortable": false }
              ]
        } );