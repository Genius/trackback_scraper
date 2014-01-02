### Rap Genius Trackback Scraper

This is the tool we used to scrape 178k URLs in 15 minutes in order to find which pages were hosting potentially spammy Rap Genius links. Given a list of URLs to scrape, it creates aggregate information that identifies the spammiest sites for manual review.

For more details on the motivation and background for this repository, check out [the blog post on Rap Genius](http://news.rapgenius.com/Rap-genius-founders-rap-genius-is-back-on-google-lyrics)

### Setup

You can run the scrape process using a set of sample data in vendor/urls.txt.  To get started:

```sh
$ bundle install && rake db:create db:migrate urls:import
$ gem install foreman
$ mkdir tmp
$ foreman start worker
```

Then, once the pages have all been scraped (i.e., `Page.unscraped.count == 0`):

```ruby
# from the console
Page.write_report!
```

### License
MIT
