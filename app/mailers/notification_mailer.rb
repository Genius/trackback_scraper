class NotificationMailer < ActionMailer::Base
  default from: "notifications@link_scraper.com"

  DEFAULT_TO_ADDRESS = ENV['SEND_NOTIFICATIONS_TO_EMAIL']

  def self.configured?
    DEFAULT_TO_ADDRESS.present? && ENV['MAILGUN_SMTP_LOGIN'].present?
  end

  def notify_success(scraped)
    mail to: DEFAULT_TO_ADDRESS,
         subject: "Finished #{scraped} pages"
  end

  def notify_error(message)
    mail to: DEFAULT_TO_ADDRESS,
         subject: "An error happened: #{message.first(50)}..."
  end

  def report(report, subject: "Completed Report", to: DEFAULT_TO_ADDRESS)
    attachments['report.csv'] = report

    mail to: to,
         subject: subject
  end
end
