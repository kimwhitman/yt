// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function hovered_images(selector) {
  $(selector).each(function() { $(this).data('orig_img', $(this).attr('src')); });
  $(selector).hover(function() {
      $(this).attr('src', $(this).attr('hoverable'));
    },
    function() {
      $(this).attr('src', $(this).data('orig_img'));
  });
}
function toggle_visibility(selector_to_show, selector_to_hide) {
    $(selector_to_show).show();
    $(selector_to_hide).hide();
}
// Smoothly transition from one div to another.
function transition_elements(selector_to_hide, selector_to_show) {
    /*
    $(selector_to_hide).hide('slide', {
        callback: function() {
            $(selector_to_show).show('slide');
        }
    });
    */
    var height = $(selector_to_hide).parent().height();
    $(selector_to_hide).parent().height(height);
    $(selector_to_hide).hide('slide', {
        callback: function() {
            $(selector_to_show).show('slide', { callback: function() {
                    $(selector_to_show).parent().animate({ height: "100%"});
                }
            });

        }
    });
}

// handles more_or_less links.
function more_or_less(link, full) {
    var p = $(link).parent().parent().parent();
    p.find('.content').toggle();
    p.find('.more_link').toggle();
    p.find('.less_link').toggle();
}

function limitText(limitField, limitNum) {
  if (limitField.value.length > limitNum)
    limitField.value = limitField.value.substring(0, limitNum);
}
