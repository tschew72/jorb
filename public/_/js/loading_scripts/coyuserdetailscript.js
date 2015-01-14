
  $('#c_firstname').editable({
    url: "/updatecoyuser",
    emptytext: '--',
    tpl: "<input type='text' style='width: 400px';height:500px>",
    validate: function(value){
      if (!value) return 'This field is required';
      if(value.length >100 ) {
        return 'You can only enter a maximum of 100 characters';
      } 
      } //function
  });

  $('#c_middlename').editable({
  	url: "/updatecoyuser",
    emptytext: '--',
    tpl: "<input type='text' style='width: 400px';height:500px>",
    validate: function(value){
      if(value.length >100 && value!=NULL) {
        return 'You can only enter a maximum of 100 characters';
    } 
      }   //function 
  });

  $('#c_surname').editable({
    url: "/updatecoyuser",
    emptytext: '--',
    tpl: "<input type='text' style='width: 400px';height:500px>",
    validate: function(value){
      if (!value) return 'This field is required';
      if(value.length >100 ) {
        return 'You can only enter a maximum of 100 characters';
      }  
      }
  });
  $('#c_email').editable({
    url: "/updatecoyuser",
    emptytext: '--',
    tpl: "<input type='text' style='width: 400px';height:500px>",
    validate: function(value){
      if(value.length >200 ) {
        return 'You can only enter a maximum of 200 characters';
      }  
      }  //function
  });
  $('#c_contactnumber').editable({
  	url: "/updatecoyuser",
    emptytext: '--',
    tpl: "<input type='text' style='width: 300px';height:500px>",
    validate: function(value){
      if(value.length >20  && value!=NULL) {
        return 'You can only enter a maximum of 20 characters';
      }
    }  //function
  });
  $('#c_password').editable({
  	url: "/updatecoyuser",
    emptytext: '--',
    tpl: "<input type='text' style='width: 200px';height:500px>",
    validate: function(value){
      if (!value) return 'This field is required';
      } //function
  });

  // $('.c_accesslevel').editable({    // Only for use in Jorb Admin
  //   source: [
  //             {value: 1, text: 'Admin Rights'},
  //             {value: 2, text: 'Job Posting Rights'},
  //          ],
  //   emptytext: '--',
  //   validate: function(value){
  //     if (!value) return 'This field is required';
  //     } //function
  // });
