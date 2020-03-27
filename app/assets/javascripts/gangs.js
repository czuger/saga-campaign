// This part is for the gang creation and the gang icon selection
// Faction part

// Gang part
const set_gang_icon_selection = function() {
    $('.gang_icon').click(function(){
        $('.gang_icon').removeClass('selected_gang_icon');
        select_gang_icon($(this))
    })
};

const select_random_gang_icon = function() {
    console.log( $('.gang_icon:visible') );

    var selected_icon = _.sample($('.gang_icon:visible'));
    select_gang_icon($(selected_icon))
};

const select_gang_icon = function( icon ){
    console.log(icon.attr('gang_icon_name'))
    icon.addClass('selected_gang_icon');
    $('#gang_icon').val( icon.attr('gang_icon_name') )
}

const change_gang_location = function() {
    $('.location_selector').change(
        function(){

            var selected_loc = $(this).val();
            var s = selected_loc.split('#');

            var loc = s[0];
            var gang_id = s[1];

            $.post( "/gangs/" + gang_id + "/change_location", { location: loc } );
        }
    )
};

// Initialisation
$(function() {
    if (window.location.pathname.match( /players\/\d+\/gangs\/new/ )) {
        set_gang_icon_selection();
        select_random_gang_icon();
    }

    console.log( window.location.pathname );
    if (window.location.pathname.match( /campaigns\/\d+\/gangs/ )) {
        change_gang_location();
    }
});