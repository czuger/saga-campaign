// Initialisation
$(function() {
    if (window.location.pathname.match( /campaigns\/\d+\/initiative_edit/ )) {
        $( "#sortable" ).sortable(
            {
                stop: function(){
                    console.log('stop');

                    var result = [];
                    $("#sortable").children().each(function( index ){
                        result.push( [ $(this).attr('player_id'), index + 1 ] );
                    });

                    console.log( result );

                    var campaign_id = $("#campaign_id" ).val()

                    $.post( "/campaigns/" + campaign_id + "/initiative_save", { new_order: result } )
                }
            }
        );
        $( "#sortable" ).disableSelection();
    }
});