const fights_input = function(){
    var v = new Vue({
        el: "#fight_results",
        data: {
            selected_btn: null
        },
        methods: {
            input_remains: function ( unit_id ) {
                var remains = $( '#remains_' + unit_id ).val();

                var request = $.ajax({
                    url: '/units/' + unit_id + '/remains',
                    method: "PATCH",
                    data: { remains: remains }
                });

                request.fail(function( jqXHR, textStatus ) {
                    console.log( "Request failed: " + textStatus );
                });
            }
        }
    });
};

$(function() {
    if (window.location.pathname.match( /fights/ )) {
        fights_input()
    }
});