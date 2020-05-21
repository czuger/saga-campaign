// Unit type part
const set_units_vue = function(){
    var v = new Vue({
        el: "#unit_edit_form",
        data: {
            selected_libe: null,
            selected_weapon: null,

            update_number_field: null,

            libe_select_options: '',
            weapon_select_options: ''
        },
        watch: {
            selected_libe: function (event) {
                v.weapon_select_options = weapon_select_data[event];
                v.selected_weapon = v.weapon_select_options[0].id;

                var unit_data = units_data[v.selected_libe][v.selected_weapon];

                if( hash_for_vue_js.on_edit ){
                    v.update_number_field = hash_for_vue_js.current_amount;
                }
                else{
                    v.update_number_field = unit_data.amount;
                }

                var ua = $('#unit_amount');
                ua.attr('min', unit_data.min);

                if( hash_for_vue_js.troop_maintenance || !hash_for_vue_js.can_add_units ){
                    var max_units = v.update_number_field;
                }else{
                    var max_units = unit_data.max;
                }
                var max_affordable_units =
                    ( unit_data.amount / unit_data.cost ) * hash_for_vue_js.player_pp + hash_for_vue_js.current_amount;

                console.log( max_affordable_units );
                max_units = Math.min( max_units, max_affordable_units );

                ua.attr('max', max_units);
                ua.attr('step', unit_data.increment_step);

                set_unit_amount_change( unit_data.amount );
            },
            update_number_field: function( event ) {
                set_unit_amount_change( event );
            }
        }
    });

    var hash_for_vue_js = JSON.parse( $('#hash_for_vue_js').val() );
    console.log( hash_for_vue_js );

    var units_data = hash_for_vue_js.units_data;

    v.libe_select_options = hash_for_vue_js.libe_select_data;
    v.selected_libe = hash_for_vue_js.selected_libe;

    var weapon_select_data = hash_for_vue_js.weapons_select_data;
    v.weapon_select_data = weapon_select_data[ v.selected_libe ];
    v.selected_weapon = hash_for_vue_js.selected_weapon;

    const set_unit_amount_change = function(new_amount ) {
        var unit_data = units_data[v.selected_libe][v.selected_weapon];
        $('#unit_points').val( ( parseFloat( new_amount ) / unit_data.amount ) * unit_data.cost );
    };
};

// Initialisation
$(function() {
    if ( window.location.pathname.match( /units\/\d+\/edit/ ) ||
        window.location.pathname.match( /gangs\/\d+\/units/ ) ) // Don't be so strict we have to catch after update and create routes (on errors)
    {
        set_units_vue();
    }
});