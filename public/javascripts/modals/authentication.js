// TODO: client-side validations
YT_Authentication = {

  handleError: function(selector, request, errorType) {
    var msg = '<div class="error">' + request.responseText + '</div>';
    selector.html(msg);
  },

  submitForgotPassword: function() {
    $('#ajax_forgot').submit(function() {

      $(this).ajaxSubmit({
        target: '#ajax_forgot .messages',
        clearForm: true,
        success: function(data, textStatus) {
          var msg = '<div class="notice">' + data + '</div>';
          $('#ajax_forgot .messages').html(msg);
          $('#ajax_forgot p:first').remove();
        },
        error: function(request, textStatus, errorThrown) {
          YT_Authentication.handleError($('#forgot_password_modal .messages'), request, textStatus);
        }
      });

      return false;
    });
  },

  submitLogin: function() {
    $('#ajax_login').submit(function() {

      $(this).ajaxSubmit({
        target: '#ajax_login .messages',
        clearForm: true,
        success: function(data, textStatus) {
          $('#login_modal').jqmHide();
          window.location.reload();
        },
        error: function(request, textStatus, errorThrown) {
          YT_Authentication.handleError($('#ajax_login .messages'), request, textStatus);
          $("#session_email").defaultValue('E-mail address');
        }
      });

      return false;
    });
  },

  emptyErrors: function() {
    $('#login_modal .messages').empty();
  },

  setupStyles: function() {
    $("#session_email ~ label").css('display', 'none');
    $("#session_password ~ label").css('display', 'none');
    $("#email ~ label").css('display', 'none');
  },

  setupDefaults: function() {
    $("#session_email").defaultValue('E-mail address');
    $("#session_password").defaultValue('Password');
    $("#email").defaultValue('E-mail address');
  },

  setupModals: function() {
    $('#login_modal').jqm({
      modal: false
    });

    $('#forgot_password_modal').jqm({
      modal: false
    });

    $('#login_h').click(function() {
      YT_Authentication.emptyErrors();
        $('#login_modal').jqmShow();
        // remove any flash messages so they don't confuse the user
        $('#flash').empty();
        $("#session_email").blur();
        return false;
      });

    $('#forgot_h').click(function() {
        YT_Authentication.emptyErrors();
        $('#login_modal').jqmHide();
        $('#forgot_password_modal').jqmShow();
        $("#email").blur();
        return false;
      });
  }
};

$(document).ready(function() {
  // YT_Authentication.setupModals();
  // YT_Authentication.setupStyles();
  // YT_Authentication.setupDefaults();
  // YT_Authentication.submitLogin();
  // YT_Authentication.submitForgotPassword();
});
