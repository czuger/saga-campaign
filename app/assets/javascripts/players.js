var prepared_movements_options_for_select = null;

const location_array_to_select_options = function( location, original_location ) {
    var empty_array = [ '<option value=""></option>' ];
    var options_array = prepared_movements_options_for_select[location];
    options_array = options_array.filter( x => x != original_location ).map( x => '<option value="' + x + '">' + x + '</option>' );

    var final_array = empty_array.concat( options_array );
    return final_array.join( ' ' );
};

const linked_selects = function() {
    $('.linked_select').change(
        function(){

            var selected_id = $(this).attr( 'id' );
            var original_location = $(this).attr( 'original_location' );
            var selected_value = $(this).val();

            console.log( selected_id, selected_value, location_array_to_select_options( selected_value ) );

            // var corresponding_value_options = prepared_movements_options_for_select[ selected_value ];
            // console.log( corresponding_value_options );

            var linked_select_id = selected_id.substring( 0, 14 ) + '2' + selected_id.substring( 15 );
            var linked_select = $( '#' + linked_select_id );

            // console.log( linked_select_id );
            // console.log( linked_select );


            linked_select.html( location_array_to_select_options( selected_value, original_location ) );
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
        console.log( prepared_movements_options_for_select );

        linked_selects();

        return sort_gangs();
    }
});