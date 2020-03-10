const load = function() {
    $('#select_location').change(
        function(){
            var selected_loc = $( "#select_location" ).val()
            var s = selected_loc.split('#')

            var loc = s[0]
            var gang_id = s[1]

            $.post( "/gangs/" + gang_id + "/change_location", { location: loc } );
        }
    )
};

$(function() {
    if (window.location.pathname.match( /campaigns\/\d+\/players/ )) {
        return load();
    }
});