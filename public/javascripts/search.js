function toggle_filter(element) {
  var arrow_img = '';
  if ($(element).hasClass('hidden'))
    arrow_img = '/images/filter-arrow-open.png';
  else
    arrow_img = '/images/filter-arrow-close.png';
  $('.filter_actions', element).toggle();
  $('.filter_arrow img', element).attr('src', arrow_img);
  $(element).toggleClass('hidden');  
  $(element).next('.filter_options').toggle();
}
function toggle_header_check_status(element) {
  var checked = $(element).parents('.filter_options.nested').find('input:checkbox:checked').length > 0;
  $(element).parents('.filter_options.nested').prev('.filter_option_box').children('.header_checkbox').attr('checked', checked);  
}