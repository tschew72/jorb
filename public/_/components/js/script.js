$(document).ready(function(){

    $('.smooth-overflow').on('scroll', function () {
        if ($(this).scrollTop() > 100) {
            $('.scroll-top-wrapper').addClass('show')
        } else {
            $('.scroll-top-wrapper').removeClass('show')
        }
    });
    $('.scroll-top-wrapper').on('click', scrollToTop);



});

 
 function scrollToTop() {
        var verticalOffset = typeof (verticalOffset) != 'undefined' ? verticalOffset : 0;
        var element = $('body');
        var offset = element.offset();
        var offsetTop = offset.top;
        $('.smooth-overflow').animate({
            scrollTop: offsetTop
        }, 400, 'linear')
    }


