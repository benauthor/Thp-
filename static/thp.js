$.jQTouch({
    icon: 'jqtouch.png',
    statusBar: 'black-translucent',
    preloadImages: []
});

$(function(){
    // This prevents scrolling
    $('#home').bind('touchmove',function(){
        event.preventDefault();
    });
    $('a').mouseout(function(){
                    $(this).removeClass('active');
                    return false;
                });
    $('a.playsong').bind('tap', function(event){
                    var title = $(this).children('h2').text();
                    $('#songtitle').text(title);
                });
});

