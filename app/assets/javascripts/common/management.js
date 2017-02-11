// for modal
$(".ui.negative.button").click(function(){
  $('.form-group.has-error').each(function(){
    $('.help-block').html('');
    $(this).removeClass('has-error');
  });
});

//....................add modal
$("#btnAddModal").click(function(){
  $('#addModal').modal('show');
});

//------------------------- show modal
$('[id^="btnViewModal_"]').each(function(i, el){
  el = $(el);
  var name_id = el.attr('id');
  var id = name_id.substr(name_id.lastIndexOf("_")+1);
  $(this).click(function(){
    $('#viewModal_' + id)
    .modal('show');
  });
});

//------------------------- edit modal
$('[id^="btnEditModal_"]').each(function(i, el){
  el = $(el);
  var name_id = el.attr('id');
  var id = name_id.substr(name_id.lastIndexOf("_")+1);
  $(this).click(function(){
    $('#editModal_' + id).modal('setting', {
      onShow: function() {
        if ($('body').hasClass("nav-md")) {
          $('body').toggleClass("nav-md nav-sm");
        }
      },
      onHide: function(){
        $('.form-group.has-error').each(function(){
          $('.help-block').html('');
          $(this).removeClass('has-error');
        });
      }
    }).modal('show');
  });
});

//------------------------- delete modal
$('[id^="btnDeleteModal_"]').each(function(i, el){
  el = $(el);
  var name_id = el.attr('id');
  var id = name_id.substr(name_id.lastIndexOf("_")+1);
  $(this).click(function(){
    $('#deleteModal_' + id).modal('setting', {
      onShow: function() {
        if ($('body').hasClass("nav-md")) {
          $('body').toggleClass("nav-md nav-sm");
        }
      },
      onHide: function(){
        $('.form-group.has-error').each(function(){
          $('.help-block').html('');
          $(this).removeClass('has-error');
        });
      }
    }).modal('show');
  });
});

//------------------------- show modal
$('[id^="btnPayModal_"]').each(function(i, el){
  el = $(el);
  var name_id = el.attr('id');
  var id = name_id.substr(name_id.lastIndexOf("_")+1);
  $(this).click(function(){
    $('#payModal_' + id).modal('setting', {
      onShow: function() {
        if ($('body').hasClass("nav-md")) {
          $('body').toggleClass("nav-md nav-sm");
        }
      },
      onHide: function(){
        $('.form-group.has-error').each(function(){
          $('.help-block').html('');
          $(this).removeClass('has-error');
        });
      }
    }).modal('show');
  });
});

// autocomplete citizen name for edit ground
$('[id^="owner_name_search_edit_"]').each(function(i, el){
  el = $(el);
  var name_id = el.attr('id');
  var id = name_id.substr(name_id.lastIndexOf("_")+1);
  $(this).autocomplete({
    source: '/citizens/autocomplete.json',
    appendTo: "#editModal_" + id,
    messages: {
      noResults: '',
      results: function() {}
    },
    select: function( event, ui ) {
      $( "#owner_name_search_edit_" + id).val( ui.item.name );
      $( "#ground_owner_id_edit_" + id).val( ui.item.key );
      return false;
    },
    change: function (event, ui) {
      if (ui.item == null || ui.item == undefined) {
        $("#owner_name_search_edit_" + id).val("");
        $("#ground_owner_id_edit_" + id).val("");
        $("#owner_name_search_edit_" + id).attr("disabled", false);
      }
    }
  });
});

// autocomplete ground name for edit modal
$('[id^="ground_name_search_edit_"]').each(function(i, el){
  el = $(el);
  var name_id = el.attr('id');
  var id = name_id.substr(name_id.lastIndexOf("_")+1);
  $(this).autocomplete({
    source: '/grounds/autocomplete.json',
    appendTo: "#editModal_" + id,
    messages: {
      noResults: '',
      results: function() {}
    },
    select: function( event, ui ) {
      $( "#ground_name_search_edit_" + id).val( ui.item.value );
      $( "#ground_name_id_edit_" + id).val( ui.item.key );
      return false;
    },
    change: function (event, ui) {
      if (ui.item == null || ui.item == undefined) {
        $("#ground_name_search_edit_" + id).val("");
        $("#ground_name_id_edit_" + id).val("");
        $("#ground_name_search_edit_" + id).attr("disabled", false);
      }
    }
  });
});

// autocomplete card_no for edit vehicle finances
$('[id^="card_no_search_edit_"]').each(function(i, el){
  el = $(el);
  var name_id = el.attr('id');
  var id = name_id.substr(name_id.lastIndexOf("_")+1);
  $(this).autocomplete({
    source: '/vehicle_cards/autocomplete.json',
    appendTo: "#editModal_" + id,
    messages: {
      noResults: '',
      results: function() {}
    },
    select: function( event, ui ) {
      $( "#card_no_search_edit_" + id).val( ui.item.value );
      $( "#card_no_id_edit_" + id).val( ui.item.key );
      return false;
    },
    change: function (event, ui) {
      if (ui.item == null || ui.item == undefined) {
        $("#card_no_search_edit_" + id).val("");
        $("#card_no_id_edit_" + id).val("");
        $("#card_no_search_edit_" + id).attr("disabled", false);
      }
    }
  });
});

// format date picker
$('.datepicker').datepicker({
  format: 'dd/mm/yyyy'
});
$('.monthpicker').datepicker({
  format: 'mm/yyyy',
  startView: "months",
  minViewMode: "months"
});
