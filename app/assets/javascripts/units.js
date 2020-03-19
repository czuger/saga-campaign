// Unit type part

var weapon_select_options_prepared_strings = null;
var units_data = null;

const set_unit_type_selection = function() {
    $('#unit_libe').change(
        function() {
            var selected_unit_type = $( "#unit_libe" ).val();
            $('#unit_weapon').html( weapon_select_options_prepared_strings[selected_unit_type] );

            $('#unit_weapon').trigger('change');
    });
};

const set_weapon_selection = function() {
    $('#unit_weapon').change(
        function() {
            var selected_unit_type = $( "#unit_libe" ).val();
            var selected_weapon_type = $( "#unit_weapon" ).val();

            var unit_data = units_data[selected_unit_type][selected_weapon_type];

            $('#unit_amount').val( unit_data.amount );
            $('#unit_amount').attr( 'min', unit_data.min );
            $('#unit_amount').attr( 'max', unit_data.max );

            $('#unit_amount').attr( 'step', unit_data.increment_step );

            $('#unit_points').val( unit_data.cost );
        });
};

const set_unit_amount_change = function() {
    $('#unit_amount').change(
        function() {
            var selected_unit_type = $( "#unit_libe" ).val();
            var selected_weapon_type = $( "#unit_weapon" ).val();

            var unit_data = units_data[selected_unit_type][selected_weapon_type];

            var cost = parseFloat( $('#unit_amount').val() / unit_data.amount ) * unit_data.cost;
            $('#unit_points').val( cost );
        });
};


// Initialisation
$(function() {
    if (window.location.pathname.match( /units/ )) {

        console.log($('#weapon_select_options_prepared_strings').val())
        weapon_select_options_prepared_strings = JSON.parse( $('#weapon_select_options_prepared_strings').val() );
        units_data = JSON.parse( $('#units_data').val() );
        console.log(units_data);

        set_unit_type_selection();
        set_weapon_selection();
        set_unit_amount_change();

        // $('#unit_libe').val( 'seigneur' ).trigger('change');
        // $('#unit_weapon').val( '-' ).trigger('change');
    }
});