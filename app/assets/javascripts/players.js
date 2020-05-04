var prepared_movements_options_for_select = null;
var forbidden_movements = null;

const location_array_to_select_options = function( location, original_location ) {
    var empty_array = [ '<option value=""></option>' ];
    var options_array = prepared_movements_options_for_select[location];

    // console.log( options_array, forbidden_movements );
    // We can't move to opponent city
    options_array = _.difference( options_array, forbidden_movements )

    options_array = options_array.filter( x => x != original_location ).map( x => '<option value="' + x + '">' + x + '</option>' );

    var final_array = empty_array.concat( options_array );
    return final_array.join( ' ' );
};

const linked_selects = function() {
    $('.linked_select').change(
        function(){

            var selected_id = $(this).attr( 'id' );
            var original_location = $(this).attr( 'original_location' );
            var selected_value = $(this).val();

            var linked_select_id = selected_id.substring( 0, 14 ) + '2' + selected_id.substring( 15 );
            var linked_select = $( '#' + linked_select_id );

            linked_select.html( location_array_to_select_options( selected_value, original_location ) );
        }
    )
};

const set_btn_sortable = function(){
    var v = new Vue({
        el: "#movement_table",
        data: {
            selected_btn: null
        },
        methods: {
            select_btn: function ( gang_id ) {
                if( this.selected_btn == null ){
                    var r = $( '#gang_name_' + gang_id );

                    r.removeClass( 'btn-primary' );
                    r.addClass( 'btn-success' );

                    this.selected_btn = gang_id;
                }
                else{
                    if( this.selected_btn != gang_id ){
                        var from = $( '#gang_id_' + this.selected_btn );
                        var to = $( '#gang_id_' + gang_id );

                        p = from.detach();
                        p.insertBefore( to );

                        this.selected_btn = null;

                        var order = [];
                        $("#sortable_gangs_table").children().each(function(){
                            order.push( $(this).attr('gang_id') );
                        });

                        $("#gangs_order" ).val( order );
                    }
                    else
                    {
                        this.selected_btn = null;
                    }

                    $( '.gang-btn' ).removeClass( 'btn-success' );
                    $( '.gang-btn' ).addClass( 'btn-primary' );
                }
            }
        }
    });
};

$(function() {
    if (window.location.pathname.match( /players\/\d+\/schedule_movements_edit/ )) {

        set_btn_sortable();

        prepared_movements_options_for_select = JSON.parse( $('#prepared_movements_options_for_select').val() );
        forbidden_movements = JSON.parse( $('#forbidden_movements').val() );

        linked_selects();
    }
});