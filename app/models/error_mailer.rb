class ErrorMailer < ActionMailer::Base

  def error(exception, opts = {})
    setup_email('bugs@planetargon.com')
    @body[:content] = exception
    @body[:backtrace] = exception.backtrace
    @body[:server] = HOST_NAME
    @body[:options] = opts.collect{|key, value| "#{key}=#{value}"}.join(', ')
  end

  def bill_failure(user)
    setup_email('bugs@planetargon.com, jamie@yogatoday.com')
    @subject     = "[YogaToday] Billing failure - #{ user.email }"
    @body[:user] = user
  end


  protected

    def setup_email(recipients)
      @recipients  = "#{ recipients }"
      @from        = "exceptions@yogatoday.com"
      @subject     = "[YogaToday] Exception has occurred"
      @sent_on     = Time.now
    end
end
