# lib/tasks/deadweight.rake

begin
  require 'deadweight'
rescue LoadError
end

Deadweight::RakeTask.new do |dw|
  dw.root = 'http://yoga.local'

  dw.stylesheets = %w(/stylesheets/yoga_main.css
                      /stylesheets/yoga_type.css
                      /stylesheets/main.css
                      /stylesheets/jqModal/jqModal.css)

  dw.pages = %w(
   /
   /about
   /advertising
   /contact
   /faqs
   /home
   /instructors
   /media-downloads
   /press-and-news
   /privacy-policy
   /promotions-and-events
   /terms-and-conditions
   /get-started-today
   /cart
   /playlist
   /checkout

   /users
   /users/new
   /session/new
   /videos/search
   /videos
   /user_stories
   /user_stories/new
   /forgot-password
   /admin
   /sign-out

   /login
   /logout

   /sign-up
   /signup
   /signup/thanks

   /account/plan
   /account/billing
   /account/cancel
   /account/paypal
   /account/thanks
   /account/dashboard
   /account/plans
   /account/canceled
   /account
   /account/new
   /account/edit
  )

end