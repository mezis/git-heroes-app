if ENV.fetch('EMAIL_ENABLED') =~ /on|true|yes/i
  ActionMailer::Base.smtp_settings = {
    port:            '25', # or 2525
    address:         ENV.fetch('POSTMARK_SMTP_SERVER'),
    user_name:       ENV.fetch('POSTMARK_API_TOKEN'),
    password:        ENV.fetch('POSTMARK_API_TOKEN'),
    domain:          ENV.fetch('HOSTNAME'),
    authentication:  :cram_md5, # or :plain for plain-text authentication
    enable_starttls_auto:  true, # or false for unencrypted connection
  }
  ActionMailer::Base.delivery_method = :smtp
end
