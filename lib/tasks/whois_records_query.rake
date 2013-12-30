desc 'scrape whois contacts'
task 'whois:scrape' do
  domains = CSV.parse(File.read(Rails.root.join('vendor/domain_lookups.csv'))).drop(1).map(&:first).map(&:strip)

  w = Whois::Client.new

  CSV.open(Rails.root.join('tmp', 'domain_lookups_output.csv'), 'wb') do |csv|
    csv << %w(domain contact)

    domains.each do |d|
      domain =
        if d =~ /^(\d+\.?)+$/
          d
        else
          d.split('.').last(2).join('.')
        end

      tries = 0

      begin
        email = w.lookup(domain).technical_contact.try(:email)
      rescue Whois::WebInterfaceError, Whois::NoInterfaceError
      rescue Timeout::Error, Whois::ConnectionError => e
        tries += 1
        retry if tries <= 5
      rescue => e
        puts "Error:"
        puts [d, e].inspect
      end

      csv << [d, email || 'Unknown']
    end
  end
end
