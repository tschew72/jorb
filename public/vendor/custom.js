   $.fn.editable.defaults.mode = 'popup'; 
   $(document).ready(function() {
      
      $('#firstname').editable();
      $('#lastname').editable();
      $('#age').editable();
      $('#gender').editable({   
        source: [
          {value: "M", text: 'Male'},
          {value: "F", text: 'Female'},
        ]
      });
      

      $('#contactnumber').editable();
      $('#address').editable();
      $('#email').editable();




   });  //end of ready(function)


      
