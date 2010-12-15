Savon::Request.log = Logger.new("#{RAILS_ROOT}/log/soap_#{RAILS_ENV}.txt")
Savon::Response.raise_errors = false
