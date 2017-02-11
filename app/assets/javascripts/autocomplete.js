$(function() {
  // autocomplete citizen name for add ground
  $("#owner_name_search_add").autocomplete({
    source: '/citizens/autocomplete.json',
    appendTo: "#addModal",
    select: function(event, ui) {
      $( "#owner_name_search_add" ).val( ui.item.name );
      $( "#ground_owner_id_add" ).val( ui.item.key );
      $( "#owner_name_search_add" ).removeClass("alert alert-danger");
      return false;
    },
    messages: {
        noResults: '',
        results: function() {}
    },
    change: function (event, ui) {
      if (ui.item == null || ui.item == undefined) {
        $("#owner_name_search_add").val("");
        $("#ground_owner_id_add").val("");
        $("#owner_name_search_add").attr("disabled", false);
      }
    },
    search: function(event, ui) {
      $("#owner_name_search_add").addClass("alert alert-danger");
    }
  });

  // autocomplete ground name for add modal
  $("#ground_name_search_add").autocomplete({
    source: '/grounds/autocomplete.json',
    appendTo: "#addModal",
    select: function( event, ui ) {
      $( "#ground_name_search_add" ).val( ui.item.value );
      $( "#ground_name_id_add" ).val( ui.item.key );
      return false;
    },
    messages: {
        noResults: '',
        results: function() {}
    },
    change: function (event, ui) {
      if (ui.item == null || ui.item == undefined) {
        $("#ground_name_search_add").val("");
        $("#ground_name_id_add").val("");
        $("#ground_name_search_add").attr("disabled", false);
      }
    }
  });

  // autocomplete card_no for vehicle finances
  $("#card_no_search_add").autocomplete({
    source: '/vehicle_cards/autocomplete.json',
    appendTo: "#addModal",
    select: function( event, ui ) {
      $( "#card_no_search_add" ).val( ui.item.value );
      $( "#card_no_id_add" ).val( ui.item.key );
      return false;
    },
    messages: {
        noResults: '',
        results: function() {}
    },
    change: function (event, ui) {
      if (ui.item == null || ui.item == undefined) {
        $("#card_no_search_add").val("");
        $("#card_no_id_add").val("");
        $("#card_no_search_add").attr("disabled", false);
      }
    }
  });
});

