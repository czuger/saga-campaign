// Unit type part
const set_units_vue = function(){
    var v = new Vue({
        el: "#unit_edit_form",
        data: {
            selected_libe: null,
            selected_weapon: null,
            update_number_field: null,
            libe_select_options: '',
            weapon_select_options: '',
        },
        watch: {
            selected_libe: function (event) {
                v.weapon_select_options = weapon_select_data[event];
                v.selected_weapon = v.weapon_select_options[0].id;

                var unit_data = units_data[v.selected_libe][v.selected_weapon];
                // console.log( unit_data );

                // $('#unit_amount').val( unit_data.amount );
                v.update_number_field = unit_data.amount;

                $('#unit_amount').attr('min', unit_data.min);
                $('#unit_amount').attr('max', unit_data.max);

                $('#unit_amount').attr('step', unit_data.increment_step);

                set_unit_amount_change( unit_data.amount )
            },
            update_number_field: function( event ) {
                set_unit_amount_change( event )
            }
        }
    });

    v.libe_select_options = JSON.parse( $('#libe_select_data').val() );
    v.selected_libe = $('#selected_libe').val();

    var weapon_select_data = JSON.parse( $('#weapons_select_data').val() );
    v.weapon_select_data = weapon_select_data[ v.selected_libe ];
    v.selected_weapon = $('#selected_weapon').val();

    var units_data = JSON.parse( $('#units_data').val() );

    const set_unit_amount_change = function(new_amount ) {
        var unit_data = units_data[v.selected_libe][v.selected_weapon];
        $('#unit_points').val( ( parseFloat( new_amount ) / unit_data.amount ) * unit_data.cost );
    };

}

// Initialisation
$(function() {
    if ( window.location.pathname.match( /units\/\d+\/edit/ ) ||
        window.location.pathname.match( /gangs\/\d+\/units\/new/ ) ) {
        set_units_vue();
    }
});