function validate_login_form(selector) {
    $(selector).validate({
        submitHandler: function(form) {
            $(form).ajaxSubmit({
                dataType: 'script'
            });
        },
        rules: {
            "password": "required",
            "login": "required"
        },
        messages: {
            "password": "Password required",
            "login": "Username required"
        }
    });
}