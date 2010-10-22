module UserImport
  require 'fastercsv'

  def import_constant_contact_data(filepath = nil)
    filepath ||= '/data/mailchimp/constant_contact_dump.csv'
    index = 0
    FasterCSV.foreach("#{ Rails.root }#{ filepath }") do |row|
      begin
        puts "Row #{ index } Email=#{ row[0] }"
        unless row[0].blank?
          # Add existing users to mailchimp
          if user = User.find_by_email(row[0])
            puts "Adding existing user to mailchimp..."
            user.add_to_mailchimp

            # If ConstantContact has their first and last name then add it to the user
            user.first_name = row[7] unless row[7].blank?
            user.last_name = row[9] unless row[9].blank?
            user.save if user.changed?
          else
            # User does not exist in YT database - add to Non-Members list
            puts "Adding to Other Non-Members Contact list"
            hominid = Hominid::Base.new({:api_key => MAILCHIMP_API_KEY})
            hominid.subscribe(hominid.find_list_id_by_name('Other Non-Member Contacts'), row[0],
              {:FNAME => row[7], :LNAME => row[9]}, {:email_type => 'html'})
          end

          begin
            puts "Adding to Newsletter list..."
            hominid = Hominid::Base.new({:api_key => MAILCHIMP_API_KEY})
            if hominid.subscribe(hominid.find_list_id_by_name('Newsletter'), row[0],
              {:FNAME => row[7] || '', :LNAME => row[9] || ''}, {:email_type => 'html'})
              puts "Added"

              #puts "Adding to group Newsletter..."
              #hominid = Hominid::Base.new({:api_key => MAILCHIMP_API_KEY})
              #if result = hominid.update_member(hominid.find_list_id_by_name('Other Non-Member Contacts'), row[0],
              #  { :GROUPINGS => {
              #    "Newsletter" => { "name" => "Newsletter", 'id' => "#{ MAILCHIMP_NEWSLETTER_GROUP_ID }", 'groups' => 'Newsletter' }
              #    } }, 'html', true)
              #
              #  # Successful submission. If this person was flagged for resubmission then remove that flag.
              #  puts "Success #{ row[0] }"
              #else
              #  puts "==FAILURE== #{ row[0] }"
              #end
            else
              puts "==FAILURE== #{ row[0] }"
            end

          rescue Exception => e
            puts "==EXCEPTION== #{ e.inspect }"
          end
        end

      rescue Exception => e
        puts "==EXCEPTION== #{ e.inspect }"
      end

      index += 1
    end
  end


end