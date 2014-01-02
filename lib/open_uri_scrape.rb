require 'open-uri'

class OpenUriScrape
  class FakeTyphoeusResponse < Struct.new(:success, :body, :code, :timed_out, :return_message, :total_time_ms)
    alias_method :success?, :success
    alias_method :timed_out?, :timed_out

    def total_time
      (total_time_ms || 0) / 1000.0
    end
  end

  attr_reader :batch_size, :queue, :processed, :concurrency

  def initialize(batch_size)
    @batch_size = batch_size
    @queue, @processed, = Queue.new, Queue.new
    @concurrency = ENV.fetch('HTTP_CONCURRENCY', 200).to_i
  end

  def scrape_batch
    pages = Page.reserve_batch_for_scraping(batch_size)
    pages.each { |p| queue << p }

    concurrency.times do
      Thread.new do
        until queue.empty?
          page = queue.pop
          processed << [page, fetch_response(page.url)]
        end
      end
    end

    pages.count.times do
      page, response = processed.pop

      page.scraped!(response)
      yield(response) if block_given?
    end
  rescue GracefulShutdown
    queue.clear
    pages.each { |p| p.unlock! if p.locked? }
    raise
  rescue => e
    Rails.logger.error([e.message] + e.backtrace)
    NotificationMailer.notify_error(e.message).deliver! if NotificationMailer.configured?

    raise e
  end

  private

  def fetch_response(url)
    result, error = nil, nil

    total_time = Benchmark.ms do
      begin
        Timeout.timeout(ENV.fetch('HTTP_TIMEOUT', 20).to_i) do
          result = open(url)
        end
      rescue => e
        error = e
      end
    end

    raise error if error

    FakeTyphoeusResponse.new(true, result.read, result.status.first.to_i, false, '', total_time)
  rescue Timeout::Error => e
    FakeTyphoeusResponse.new(false, nil, 0, true, nil, total_time)
  rescue OpenURI::HTTPError => e
    FakeTyphoeusResponse.new(false, nil, e.message.split.first.to_i, false, e.message, total_time)
  rescue => e
    FakeTyphoeusResponse.new(false, nil, 0, false, e.inspect, total_time)
  end
end
