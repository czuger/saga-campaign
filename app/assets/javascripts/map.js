// Initialisation
$(function() {
    if ( window.location.pathname.match( /map\/edit/ ) ) {

        console.log('In edit');

        $('#map').mousedown(function(event) {

            var searchParams = new URLSearchParams(window.location.search);
            var letter = searchParams.get('letter')

            console.log( letter, event.pageX, event.pageY );

            $.post( "/map/save_position", { letter: letter, x: event.pageX, y: event.pageY } );
        });
    }
});
