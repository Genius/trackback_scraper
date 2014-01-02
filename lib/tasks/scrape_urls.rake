desc 'scrape all urls'
task 'pages:scrape', [:limit] => :environment do |t, args|
  limit = args[:limit] || 20

  done = 0

  Page.scrape_batch(limit) do |completed_response|
    done += 1

    if done % 10 == 0
      puts "Completed #{done}"
    end
  end

  NotificationMailer.notify_success(limit).deliver! if NotificationMailer.configured?
end


desc 'delayed_job-like worker task for scraping pages'
task 'pages:work' => :environment do
  require 'graceful_shutdown'
  trap('TERM') { raise GracefulShutdown }

  batch_size = ENV.fetch('SCRAPE_BATCH_SIZE', 200).to_i

  begin
    loop do
      start = Time.now

      Rails.logger.info "Scraping batch of #{batch_size}"
      Page.scrape_batch(batch_size)
      Rails.logger.info "Done scraping batch of #{batch_size} at #{((Time.now.to_f - start.to_f) / batch_size.to_f).round(2)}seconds/page"

      sleep 10 if Page.count.zero?
    end
  rescue GracefulShutdown
  end
end
