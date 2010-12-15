Savon::Request.log = Logger.new(File.open("#{RAILS_ROOT}/log/soap_#{RAILS_ENV}.txt", 'a'))
Savon::Response.raise_errors = false
