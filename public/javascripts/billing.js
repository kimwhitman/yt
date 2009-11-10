var billing = {
  setup: function(){
    $('#billing_form').validate({
      rules: {
        'creditcard[number]': {
          required: true,
          creditcard: true
        },
        'creditcard[verification_value]': 'required',
        'creditcard[first_name]': 'required',
        'creditcard[last_name]': 'required',
        'agree_to_terms': 'required'
      },
      messages: {
        'creditcard[number]': "A valid credit card is required",
        'creditcard[verification_value]': "A Verification Value is required",
        'creditcard[first_name]': "Your First Name is required",
        'creditcard[last_name]': "Your Last Name is required",
        'user[agree_to_terms]': 'You must agree to the terms'
      }
    });
  }
}

$(document).ready(function() {
  billing.setup();
});