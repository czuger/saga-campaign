// Faction part
const on_faction_selection = function() {
    var selected_faction = $( "#select_faction" ).val();
    $('.factions_icons').hide();
    $("." + selected_faction).show();
    select_random_gang_icon();
};

const set_faction_selection = function() {
    $('#select_faction').change(on_faction_selection);
};

// Gang part
const set_gang_icon_selection = function() {
    $('.gang_icon').click(function(){
        $('.gang_icon').removeClass('selected_gang_icon');
        select_gang_icon($(this))
    })
};

const select_random_gang_icon = function() {
    var selected_icon = _.sample($('.gang_icon:visible'));
    select_gang_icon($(selected_icon))
};

const select_gang_icon = function( icon ){
    console.log(icon.attr('gang_icon_name'))
    icon.addClass('selected_gang_icon');
    $('#selected_gang_icon').val( icon.attr('gang_icon_name') )
}


// Initialisation
$(function() {
    if (window.location.pathname.match( /gangs/ )) {
        on_faction_selection();
        set_faction_selection();
        set_gang_icon_selection();
    }
});