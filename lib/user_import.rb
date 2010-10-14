module UserImport
  require 'fastercsv'

  def import_constant_contact_data(filepath = nil)
    filepath ||= '/data/mailchimp/constant_contact_dump.csv'
    FasterCSV.foreach("#{ Rails.root }#{ filepath }") do |row|
      unless row[0].blank?
        if user = User.find_by_email(row[0])
          user.add_to_mailchimp
          user.assign_mailchimp_groups
        end


      end
    end
  end


end