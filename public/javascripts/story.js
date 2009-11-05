function validate_new_story_form(selector, options) {
    settings = {
        rules: {
            "first_name": 'required',
            "city": 'required',
            "country": 'required',
            'state': 'required',
            "user_story[email]": 'required',
            "user_story[title]": 'required',
            "user_story[story]": 'required'
        },
        messages: {
            "first_name": 'A first name is required',
            "city": 'A city is required',
            "country": 'A country is required.',
            'state': 'A state is required',
            "user_story[email]": 'An email is required',
            "user_story[title]": 'A title is required',
            "user_story[story]": 'A story is required'
        }
    }
    $.extend(settings, options);
    $(selector).validate(settings);
}