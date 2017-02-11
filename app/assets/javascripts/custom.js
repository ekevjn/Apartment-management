$(function() {
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="modal"]').tooltip();
  $('.datepicker').datepicker({
    format: 'dd/mm/yyyy'
  });
  $('.monthpicker').datepicker({
    format: 'mm/yyyy',
    startView: "months",
    minViewMode: "months"
  });

  // for import excel in management
  $("#import_form").fileupload({
    dataType: "script"
  });

  // for modal
  $('.ui.modal').modal('setting', {
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
  });

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

  //------------------------- order, pagination js call
  $(document).on("click",".table-responsive th a, .table-responsive .pagination a", function() {
    $.getScript(this.href);
    return false;
  });

  $(document).on("click","#dropdown-filter a", function() {
    $.getScript(this.href);
    return false;
  });

  // Tower
  $("#towers_search #search_input").keyup(function() {
    $.get($("#towers_search").attr("action"), $("#towers_search").serialize(), null, "script");
    return false;
  });

  // Ground
  $("#grounds_search #search_input").keyup(function() {
    $.get($("#grounds_search").attr("action"), $("#grounds_search").serialize(), null, "script");
    return false;
  });

  // Building
  $("#buildings_search #search_input").keyup(function() {
    $.get($("#buildings_search").attr("action"), $("#buildings_search").serialize(), null, "script");
    return false;
  });

  // Citizen
  $("#citizens_search #search_input").keyup(function() {
    $.get($("#citizens_search").attr("action"), $("#citizens_search").serialize(), null, "script");
    return false;
  });

  // Facility
  $("#facilitys_search #search_input").keyup(function() {
    $.get($("#facilitys_search").attr("action"), $("#facilitys_search").serialize(), null, "script");
    return false;
  });

  // Maintain
  $("#maintains_search #search_input").keyup(function() {
    $.get($("#maintains_search").attr("action"), $("#maintains_search").serialize(), null, "script");
    return false;
  });

  // Citizen Card
  $("#citizen_cards_search #search_input").keyup(function() {
    $.get($("#citizen_cards_search").attr("action"), $("#citizen_cards_search").serialize(), null, "script");
    return false;
  });

  // Service
  $("#services_search #search_input").keyup(function() {
    $.get($("#services_search").attr("action"), $("#services_search").serialize(), null, "script");
    return false;
  });

  // Vehicle Card
  $("#vehicle_cards_search #search_input").keyup(function() {
    $.get($("#vehicle_cards_search").attr("action"), $("#vehicle_cards_search").serialize(), null, "script");
    return false;
  });

  // Vehicle Finance
  $("#vehicle_finances_search #search_input").keyup(function() {
    $.get($("#vehicle_finances_search").attr("action"), $("#vehicle_finances_search").serialize(), null, "script");
    return false;
  });

  // Water
  $("#waters_search #search_input").keyup(function() {
    $.get($("#waters_search").attr("action"), $("#waters_search").serialize(), null, "script");
    return false;
  });

  // History
  $("#histories_search #search_input").keyup(function() {
    $.get($("#histories_search").attr("action"), $("#histories_search").serialize(), null, "script");
    return false;
  });

  // Ground History
  $("#ground_histories_search #search_input").keyup(function() {
    $.get($("#ground_histories_search").attr("action"), $("#ground_histories_search").serialize(), null, "script");
    return false;
  });


  $('.left.demo.sidebar').first()
    .sidebar('setting', 'transition', 'overlay')
    .sidebar('attach events', '.toggle.button')
  ;
  $('.toggle.button')
    .removeClass('disabled');

  $('.ui.dropdown')
    .dropdown()
  ;

  $('.menu .item')
    .tab()
  ;

    /* ==========================================================================
   litebox
   ========================================================================== */

    $('.video-intro .play-btn, .video-tour .play-btn').magnificPopup({
        type: 'iframe'
    });

 /* ==========================================================================
   Team slider
   ========================================================================== */

   var owlTeam = $('.team-slider');
   owlTeam.owlCarousel({
    itemsCustom: [
      [0, 1],
      [450, 1],
      [600, 1],
      [700, 2],
      [1000, 3],
      [1200, 3],
      [1400, 3],
      [1600, 3]
    ],
    navigation: true,
    pagination: false,
    navigationText: [
    "<i class='fa fa-angle-left fa-2x'></i>",
    "<i class='fa fa-angle-right fa-2x'></i>"
    ]
  });
 });


