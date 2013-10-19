require 'action_mailer'

class Notifier < ActionMailer::Base
  def email(mailto,subject,ebody)
    mail(:to=>mailto,:from=>"hunter.hu@nsn.com",:subject=> subject,:body=>ebody)
  end
end
 
Notifier.delivery_method = :smtp
Notifier.smtp_settings = {
  #:address => "mail.emea.nsn-intra.net",
  :address => "10.135.40.19",
  :port => 25,
  :openssl_verify_mode  => 'none'
}

def send_email(email_address,topic,)

#Notifier.email("hunter.hu@nsn.com","adfds","dafsdf").deliver