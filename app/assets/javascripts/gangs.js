const show_corresponding_factions_icons = function() {
    var selected_faction = $( "#select_faction" ).val();
    $('.factions_icons').hide();
    $("." + selected_faction).show();
    random_icon_select();
};

const set_faction_icons_show = function() {
    $('#select_faction').change(show_corresponding_factions_icons);
};

const set_icon_select = function() {
    $('.gang_icon').click(function(){
        $('.gang_icon').removeClass('selected_gang_icon');
        $(this).addClass('selected_gang_icon');
    })
};

const random_icon_select = function() {
    var selected_icon = _.sample($('.gang_icon:visible'));

    $(selected_icon).addClass('selected_gang_icon');
};

$(function() {
    if (window.location.pathname.match( /gangs/ )) {
        show_corresponding_factions_icons();
        set_faction_icons_show();
        set_icon_select();
    }
});