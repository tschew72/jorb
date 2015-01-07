        $('#languagesettingtable').dataTable( {
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