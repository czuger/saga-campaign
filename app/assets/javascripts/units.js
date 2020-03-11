// Unit type part

var faction_data = null;

const set_unit_type_selection = function() {
    $('#unit_libe').change(
        function() {
            var selected_unit_type = $( "#unit_libe" ).val();

            var options = ""
            for (var item of faction_data[selected_unit_type]) {
                options += "<option>" + item + "</option>"
            }

            $('#weapon').html( options )
    });
};

// // Gang part
// const set_gang_icon_selection = function() {
//     $('.gang_icon').click(function(){
//         $('.gang_icon').removeClass('selected_gang_icon');
//         select_gang_icon($(this))
//     })
// };
//
// const select_random_gang_icon = function() {
//     var selected_icon = _.sample($('.gang_icon:visible'));
//     select_gang_icon($(selected_icon))
// };
//
// const select_gang_icon = function( icon ){
//     console.log(icon.attr('gang_icon_name'))
//     icon.addClass('selected_gang_icon');
//     $('#gang_icon').val( icon.attr('gang_icon_name') )
// }


// Initialisation
$(function() {
    if (window.location.pathname.match( /units/ )) {

        faction_data = JSON.parse( $('#faction_data').val() )
        console.log(faction_data)

        set_unit_type_selection();
        // set_unit_type_selection();
        // set_gang_icon_selection();
    }
});