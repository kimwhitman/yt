// Uses 1-based indexes.
function featured_video_details(index) {  
  index = parseInt(index) - 1;
  var details = video_details[index];
  $('#featured-video-info').click(function () { window.location.href=details['url'];});
  $('#feature-video-info-class-title').html(details['title']);
  $('#featured-video-skill').html(details['skill']);
  $('#featured-video-yoga-type').html(details['yoga_types']);
  $('#featured-video-instructor').html(details['instructors']);
  $('#featured-video-time').html(details['time']);
  $('#featured-videos-link').attr('href', details['url']);
  if (details['free'] == true) {
    $('#feature-video-info-free-class').show();
    $('#feature-video-info-featured-class').hide();
  }
  else {
    $('#feature-video-info-free-class').hide();
    $('#feature-video-info-featured-class').show();
  }
}

function next_featured_video(carousel) {
  var parent = $('.slider_item_box.current').parent();
  index = 0;
  if (parent.next().length == 0) {
    index = 1;
    sliderSelect($('#featured_videos_carousel .slider_item_box:first'));
  }
  else {
    index = parseInt(parent.next().attr('jcarouselindex'));
    sliderSelect(parent.next().children('.slider_item_box:first'));
  }
  carousel.scroll(index);  
  featured_video_details(index);
}
function prev_featured_video(carousel) {
  var parent = $('.slider_item_box.current').parent();
  index = 0;
  if (parent.prev().length == 0) {
    index = $('#featured_videos_carousel li').length;
    sliderSelect($('#featured_videos_carousel .slider_item_box:last'));
  }
  else {
    index = parseInt(parent.prev().attr('jcarouselindex'));
    sliderSelect(parent.prev().children('.slider_item_box:first'));
  }
  carousel.scroll(index);  
  featured_video_details(index);  
}