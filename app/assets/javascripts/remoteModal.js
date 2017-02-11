$(document).ready(function(){
  // for tower
  $(document).bind('ajaxError', 'form#new_tower', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_tower', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for ground
  $(document).bind('ajaxError', 'form#new_ground', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_ground', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for citizen
  $(document).bind('ajaxError', 'form#new_citizen', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_citizen', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for building
  $(document).bind('ajaxError', 'form#new_building', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_building', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for facility
  $(document).bind('ajaxError', 'form#new_facility', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_facility', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for maintain
  $(document).bind('ajaxError', 'form#new_maintain', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_maintain', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for services
  $(document).bind('ajaxError', 'form#new_service', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_service', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for water
  $(document).bind('ajaxError', 'form#new_water', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_water', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for citizen cards
  $(document).bind('ajaxError', 'form#new_citizen_card', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_citizen_card', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for vehicle cards
  $(document).bind('ajaxError', 'form#new_vehicle_card', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_vehicle_card', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

  // for vehicle finances
  $(document).bind('ajaxError', 'form#new_vehicle_finance', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });
  $(document).bind('ajaxError', 'form.edit_vehicle_finance', function(event, jqxhr, settings, exception){
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  });

});

(function($) {
  $.fn.modal_success = function(){
    // close modal
    this.modal('hide');
    // clear form input elements
    this.find('form input[type="text"]').val('');
    // clear error state
    this.clear_previous_errors();
  };

  $.fn.render_form_errors = function(errors){
    $form = this;
    this.clear_previous_errors();
    model = this.data('model');
    // show error messages in input form-group help-block
    $.each(errors, function(field, messages){
      $input = $('input[name="' + model + '[' + field + ']"]');
      $input.closest('.form-group').addClass('has-error').find('.help-block').html( messages.join(' & ') );
      $select = $('select[name="' + model + '[' + field + ']"]');
      $select.closest('.form-group').addClass('has-error').find('.help-block').html( messages.join(' & ') );
    });

  };

  $.fn.clear_previous_errors = function(){
    $('.form-group.has-error', this).each(function(){
      $('.help-block', $(this)).html('');
      $(this).removeClass('has-error');
    });
  }

}(jQuery));
