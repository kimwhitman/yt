var billing = {
  setup: function(){
    $('#billing_form').validate({

      rules: {
        'creditcard[number]': {
          checkcc: true,
          required:
            function(element) {
              free = $("#membership_free").is(':checked');
              bogus = $("select#creditcard_type").val() == 'bogus';

              if (free || (!free && bogus)) {
                return false;
              }
              else {
                return true;
              }
            }
        },

        'creditcard[verification_value]': {
          required:
            function() {
              return !$("#membership_free").is(':checked');
            }
        },

        'creditcard[first_name]': {
          required:
            function() {
              return !$("#membership_free").is(':checked');
            }
        },

        'creditcard[last_name]': {
          required:
            function() {
              return !$("#membership_free").is(':checked');
            }
        },
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

  // custom cc validator that'll allow bogus types
  $.validator.addMethod("checkcc", function(value, element) {
      if($("select#creditcard_type").val() == 'bogus') {
        return true;
      }

      if (/[^0-9-]+/.test(value)) {
        return false;
      }

      var nCheck = 0,
        nDigit = 0,
        bEven = false;

      value = value.replace(/\D/g, "");

      for (n = value.length - 1; n >= 0; n--) {
        var cDigit = value.charAt(n);
        var nDigit = parseInt(cDigit, 10);
        if (bEven) {
          if ((nDigit *= 2) > 9)
            nDigit -= 9;
        }
        nCheck += nDigit;
        bEven = !bEven;
      }

      return (nCheck % 10) == 0;

    },"Must be a valid credit card number.");

  billing.setup();

  // remove spaces and dashes
  $("#creditcard_number").change(function(){
    $(this).val(($(this).val().replace(/[-\s]/g, '')));
  });
});

