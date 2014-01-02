if ENV['MAILGUN_SMTP_LOGIN'].present?
  ActionMailer::Base.smtp_settings = {
      :authentication => :plain,
      :address => ENV.fetch('MAILGUN_SMTP_SERVER'),
      :port => ENV.fetch('MAILGUN_SMTP_PORT'),
      :domain => 'link_scraper.mailgun.org',
      :user_name => ENV.fetch('MAILGUN_SMTP_LOGIN'),
      :password => ENV.fetch('MAILGUN_SMTP_PASSWORD')
  }
end
