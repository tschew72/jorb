    /* This is in the Edit Experience Modal  START*/
      // if (<%= @exp.skr_emp_currentjob %>){
      //   document.getElementById( 'enddate_block' ).style.visibility = 'hidden'; 
      //  } else {
      //   document.getElementById( 'enddate_block' ).style.visibility = 'visible'; 
      //  }

      $('#e_skr_emp_currentjob').editable({disabled: true }); 

      $('#e_pk').editable({
        disabled: true
        });

      $('#e_jobid').editable({
        disabled: true
        });

      $('#e_skr_emp_company').editable({
        disabled: false,
        showbuttons: true,
        });

      $('#e_skr_emp_industry').editable({
        source: "/getind",
        disabled: false,
        onblur: 'submit',
        showbuttons: false,
        });

      $('#e_skr_emp_location').editable({
        source: "/getcountries",
        disabled: false,
        onblur: 'submit',
        showbuttons: false,
        });

      $('#e_skr_emp_function').editable({
        source: "/getfunction",
        disabled: false,
        onblur: 'submit',
        showbuttons: false,
        });

      $('#e_skr_emp_title').editable({
        source: "/getjobtitle",
        disabled: false,
        onblur: 'submit',
        showbuttons: false,
        });

      $('#e_skr_emp_actualtitle').editable();

      $('#e_skr_emp_desc').editable({
        emptytext: '--',
        // tpl: "<style='width: 400px';height:500px>",
        validate: function(value){
          if(value.length >50000 ) {
            return 'You can only enter a maximum of 50000 characters';
            
          }
        }

      });

      $('#e_skr_emp_start').editable({
        format: 'dd-mm-yyyy',    
        viewformat: 'dd/mm/yyyy',  
        onblur: 'submit',
        showbuttons: false,  
        datepicker: {
                weekStart: 1
           }
        });

      $('#e_skr_emp_end').editable({
        format: 'dd-mm-yyyy',    
        viewformat: 'dd/mm/yyyy',
        onblur: 'submit',
        showbuttons: false,    
        datepicker: {
                weekStart: 1
           }
        });      
      
      $("#e_currentjobcheck").on('change', function(){
          if($(this).is(":checked")) {
            $('#e_skr_emp_currentjob').editable('setValue',"true");
            document.getElementById( 'e_enddate_block' ).style.visibility = 'hidden'; 
          } else
          {
            $('#e_skr_emp_currentjob').editable('setValue',"false");
            document.getElementById( 'e_enddate_block' ).style.visibility = 'visible'; 
          }; 
      });

    /* This is in the Edit Experience Modal  END */