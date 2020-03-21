const set_icon_movement = function(){
    $( '.on_map_gang_icon' ).click(function(){

            console.log( $(this).attr('location') );
        }
    );
};

// Initialisation
$(function() {

    if ( window.location.pathname.match( /map\/modify_positions/ ) ) {
        set_icon_movement();
    }

    if ( window.location.pathname.match( /map\/create_positions/ ) ) {
        console.log('In edit');

        $('#map').mousedown(function(event) {

            var searchParams = new URLSearchParams(window.location.search);
            var letter = searchParams.get('letter');

            console.log( letter, event.pageX, event.pageY );

            $.post( "/map/save_position", { letter: letter, x: event.pageX, y: event.pageY } );
        });
    }
});
