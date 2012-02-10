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
    // Prevent wierd stuck buttons. TODO: improve this behavior
    $('a').mouseout(function(){
                    $(this).removeClass('active');
                    return false;
                });
    // Playlist action
    $('li.playsong').bind('tap', function(event){
                    var title = $(this).children('h2').text();
                    var id = $(this).children('p.id').text()
                    $.get('playsong/' + id, function(data) {
                        $('.songtitle').html(data);
                    });
                });
    // Refresh song title every 3 seconds
    setInterval(function() {
        $.get("status/", function(data) {
            var display = JSON.parse(data);
            $('.songtitle').html(display.current_song);
        });
    }, 3000);
});

