;(function($){
  
  'use strict';
  
  // define app
  var app;
  
  if (typeof app === 'undefined') app = {};
  
  app.plug = {
    
    // ini app
    init: function() {
      this.getTopFn();
      this.getActions();
    },
    
    
    
    mobilecheck: function () {
      var check = false;
      (function(a){if(/(android|ipad|playbook|silk|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))check = true;})(navigator.userAgent||navigator.vendor||window.opera);
      return check;
    },
    
    
    
    // make active links
    getActive_links: function(){
      $('.menu_link').on(this.mobilecheck() ? 'touchstart' : 'click',function(){
        $('.active').removeClass('active');
        $(this).addClass('active');
      });
    },
    
    
    
    // scroll to top
    getTopFn: function(){
      
      $(window).scroll(function(){
        var scrl = $(window).scrollTop();
        if (scrl > 350){$('.toTop').slideDown();}
        else{$('.toTop').slideUp();}
      });
      $('[data-fn="top"]').on(this.mobilecheck() ? 'touchstart' : 'click',function(){
        $("html, body").animate({ scrollTop: 0 },500);
        return false;
      });
    },
    
    
    getActions: function(){
      
      // Stiker fn
      $(window).scroll(function(){
        var thisTop = $(winfdow).scrollTop();
        if(thisTop <= 0){
          $('[data-fn="sticker"]').css({opacity:0}).animate({
            top:0
          },100,function(){
            $(this).css({
              position:'relative',
              opacity:1
            });
          });
        }else{
          $('[data-fn="sticker"]').css({position:'absolute'}).animate({
            top:thisTop,
            width:'100%',
            zIndex: 1000
          },100);
        }
      });
      
      
      // menu mobile
      // clone nav into mobile
      var nav = $('.menu').html();
      $('#menu_mobile').html(nav);
      
      // get active links
      app.plug.getActive_links();
      
      $('#toggle_nav').on(this.mobilecheck() ? 'touchstart' : 'click',function() {
        $(this).toggleClass('on');
        $('#menu_mobile').slideToggle();
      });
      
      
      // tabs
      $('[data-fn="tabs"]')
      .on(this.mobilecheck() ? 'touchstart' : 'click',function(e){
        e.preventDefault();
        $(this).parent()
        .addClass('tab-active')
        .siblings()
        .removeClass('tab-active');
        $('#'+ $(this).data('open'))
        .addClass('tab-open')
        .siblings()
        .removeClass('tab-open');
      });
      
      
      // accordion
      // init
      $('[data-fn="accordion"]').attr('data-set','open');
      
      $('[data-fn="accordion"]')
      .on(this.mobilecheck() ? 'touchstart' : 'click',function(e){
        e.preventDefault();
        var open = $(this).data('open');
        if($('#'+open).hasClass('accordion-open')){
          $('#'+open).removeClass('accordion-open');
          $(this).attr('data-set','open');
        }else{
          $('#'+open)
          .addClass('accordion-open')
          .parent()
          .removeClass('accordion-open');
          $(this).attr('data-set','close');
        }
      });
      
      
      
      // modal
      $('[data-fn="text"]').on(this.mobilecheck() ? 'touchstart' : 'click',function(e){
        
        e.preventDefault();
        $('.overlay').css('display','block');
        $('body').css('overflow','hidden');
        $('.modal').animate({
          left:0
        },1000);
        $('.modal').html(
        app.plug.getTextTemplate($(this).data('get'))
        );
      });
      
      
      
      $('[data-fn="img"]').on(this.mobilecheck() ? 'touchstart' : 'click',function(e){
        e.preventDefault();
        $('.overlay').css('display','block');
        $('body').css('overflow','hidden');
        $('.modal').animate({
          left:0
        },1000);
        $('.modal').html(
          app.plug.getImgTemplate($(this).data('get'),$(this).attr('title'))
        );
      });
      
      
      
      
      $('.overlay,#close')
      .on(this.mobilecheck() ? 'touchstart' : 'click',function(e){
        e.preventDefault();
        $('.modal').animate({
          left:'-200%'
        },1000,function(){
          $('.overlay').css('display','none');
          $('body').css('overflow','auto');
        });
      });
    },
    
    
    
    // templates modal
    getImgTemplate: function(img,title){
      var html = '<buttom id="close">x</buttom>' +
          '<img class="tumb" src="' +
          img + '" alr="'+ title + '"/>';
      return html;
    },
    
    getTextTemplate: function(text){
      var html = '<buttom id="close" class="b-alizarin c-clouds">x</buttom>' +
          '<p>' + text + '</p>';
      return html;
    }
    
  };
  
  $(document).ready(function(){
    app.plug.init();
  });
  
})(jQuery);
