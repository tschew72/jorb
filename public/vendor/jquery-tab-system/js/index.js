$(document).ready(function(){
  function tabs(){
    var $li = $('li.tabs');
    $li.on('click',function(e){
      e.preventDefault();
      var $this = $(this),
          $number = $this.attr('data-tab');
      $this.addClass('active');
      $li.not($this).removeClass('active');
      $('.content[data-tab*='+$number+']').css({
        display:'block'
      }).attr('data-active','true');
      $('.content:not([data-tab='+ $number +'])').css({
        display:'none'
      }).attr('data-active','false');
    });
  } 
  tabs(); 
});