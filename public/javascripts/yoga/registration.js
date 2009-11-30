function validateRegistration(selector, options) {
  settings = {

    success: function(label) {
      // set &nbsp; as text for IE
      label.html("&nbsp;").addClass("checked");
    },
    errorClass: 'form_error',
    onkeyup: false,
    rules: {
      "user[name]": {
        required: true,
        minlength: 5,
      },
      "user[email]": {
        required: true,
        email: true,
        remote: {
          url: '/users/check_email.json',
          type: 'post'
        }
      },
      "user[email_confirmation]": {
        required: true,
        equalTo: selector + " #user_email"
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
      "user[name]": {
        required: "Please provide a name",
        minlength: "Your name must be at least 5 characters long"
      },
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
        required: "Please retype your password",
        minlength: "Your password must be at least 5 characters long",
        equalTo: "Please enter the same password as above"
      },
      "user[email_confirmation]": {
        required: "Please retype your email",
        minlength: "Your email must be at least 5 characters long",
        equalTo: "Please enter the same email as above"
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