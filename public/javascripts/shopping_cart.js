// TODO
// I've disabled purchase[card_number] validation for the sake of
// testing.
function validate_purchase_form(selector, options) {
  settings = {
    rules: {
      'purchase[first_name]': 'required',
      'purchase[last_name]': 'required',
      'purchase[email]': {
        required: true,
        email: true
      },
      'purchase[card_type]': 'required',
      'purchase[card_expiration(1i)]': 'required',
      'purchase[card_expiration(2i)]': 'required',
      'purchase[card_number]': {
        required: true,
        creditcard: true 
      },
      'purchase[card_verification]': 'required'
    },
    messages: {
      'purchase[first_name]': 'A first name is required',
      'purchase[last_name]': 'A last name is required',
      'purchase[email]': 'A valid email is required',
      'purchase[card_type]': 'A card type is required',
      'purchase[card_expiration(1i)]': 'Year is required',
      'purchase[card_expiration(2i)]': 'Day is required',
      'purchase[card_number]': {
        required: 'A card number is required',
        creditcard: 'This does not appear to be a credit card number.'
      },
      'purchase[card_verification]': 'Card verification is required'
    }
  };
  $.extend(settings, options);
  $(selector).validate(settings);
}