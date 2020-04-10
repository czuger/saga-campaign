var prepared_movements_options_for_select = null;

const linked_selects = function() {
    $('.linked_select').change(
        function(){

            var selected_id = $(this).attr( 'id' );
            var selected_value = $(this).val();

            // console.log( selected_id, selected_value );

            var corresponding_value_options = prepared_movements_options_for_select[ selected_value ];
            console.log( corresponding_value_options );

            var linked_select_id = selected_id.substring( 0, 14 ) + '2' + selected_id.substring( 15 );
            var linked_select = $( '#' + linked_select_id );

            // console.log( linked_select_id );
            // console.log( linked_select );

            linked_select.html( corresponding_value_options );
        }
    )
};

// Initialisation
const sort_gangs = function() {
    $( "#sortable_gangs_table" ).sortable(
        {
            stop: function(){
                var order = [];
                $("#sortable_gangs_table").children().each(function(){
                    order.push( $(this).attr('gang_id') );
                });

                $("#gangs_order" ).val( order );
            }
        }
    );
    $( "#sortable" ).disableSelection();
}

$(function() {
    if (window.location.pathname.match( /players\/\d+\/schedule_movements_edit/ )) {

        prepared_movements_options_for_select = JSON.parse( $('#prepared_movements_options_for_select').val() );

        linked_selects();
        return sort_gangs();
    }
});