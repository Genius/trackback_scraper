desc 'import urls from a file'
task 'urls:import' => :environment do
  urls = File.read(Rails.root.join('vendor', 'urls.txt'))
  urls.each_line.drop(1).each do |url|
    url = url.strip

    Page.find_or_create_by_url!(url)
  end
end
