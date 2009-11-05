function validate_new_user_form(selector, options) {
  settings = {
    onkeyup: false,
    rules: {
      "user[email]": {
        required: true,
        email: true,
        remote: {
          url: '/users/check_email.json',
          type: 'post'
        }
      },
      "user[password]": {
        required: true,
        minlength: 5
      },
      "user[password_confirmation]": {
        required: true,
        minlength: 5,
        equalTo: selector + " #user_password"
      }
    },
    messages: {
      "user[email]": {
        required: "Please enter your email address",
        email: "Please enter a valid email address",
        remote: "That email address is already taken"
      },
      "user[password]": {
        required: "Please provide a password",
        minlength: "Your password must be at least 5 characters long"
      },
      "user[password_confirmation]": {
        required: "Please confirm your password",
        minlength: "Your password must be at least 5 characters long",
        equalTo: "Please enter the same password as above"
      }
    }
  }
  $.extend(settings, options);
  $(selector).validate(settings);
  // check if confirm password is still valid after password changed
  $(selector).find("#user_password").blur(function() {
    $(selector).find("#user_password_confirmation").valid();
  });
}