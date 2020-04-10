const load = function() {
    $('.location_selector').change(
        function(){

            console.log($(this));

            var selected_loc = $(this).val();
            var s = selected_loc.split('#');

            var loc = s[0];
            var gang_id = s[1];

            $.post( "/gangs/" + gang_id + "/change_location", { location: loc } );
        }
    )
};

// Initialisation
const sort_gangs = function() {
    $( "#sortable_gangs_table" ).sortable(
        {
            stop: function(){
                // console.log('stop');

                var order = [];
                $("#sortable_gangs_table").children().each(function(){
                    order.push( $(this).attr('gang_id') );
                });

                console.log( order );

                $("#gangs_order" ).val( order );

                // $.post( "/campaigns/" + campaign_id + "/initiative_save", { new_order: result } )
            }
        }
    );
    $( "#sortable" ).disableSelection();
}

$(function() {
    if (window.location.pathname.match( /players\/\d+\/schedule_movements_edit/ )) {
        return sort_gangs();
    }
});