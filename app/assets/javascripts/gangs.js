const show_corresponding_factions_icons = function() {
    $('.factions_icons').hide();
    var selected_faction = $( "#select_faction" ).val();
    console.log(selected_faction);
    console.log($("." + selected_faction))
};

const set_faction_icons_show = function() {
    $('#select_faction').change(show_corresponding_factions_icons)
};

$(function() {
    if (window.location.pathname.match( /gangs/ )) {
        show_corresponding_factions_icons();
        set_faction_icons_show();
    }
});