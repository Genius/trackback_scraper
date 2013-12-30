class ParsedLink
  include StringHelper

  attr_accessor :rg_link, :song_page_link, :annotation_link, :lyrics_text_link, :rg_text_format, :inner_text, :href
  alias_method :rg_link?, :rg_link
  alias_method :song_page_link?, :song_page_link
  alias_method :annotation_link?, :annotation_link
  alias_method :lyrics_text_link?, :lyrics_text_link
  alias_method :rg_text_format?, :rg_text_format

  def initialize(link)
    return unless self.href = link['href'].presence
    self.href = coerce_to_utf8(href)

    begin
      parsed = Addressable::URI.parse(href)
    rescue Addressable::URI::InvalidURIError
      return
    end

    return unless parsed.host =~ /(?:^|\.)rapgenius.com\z/i
    self.rg_link = true

    path, self.inner_text = coerce_to_utf8(parsed.path), coerce_to_utf8(link.inner_text)

    if path =~ /-lyrics\z/i
      self.song_page_link = true

      if inner_text =~ /\sLyrics\z/
        self.lyrics_text_link = true

        artist, title = link.inner_text.split(/\s+–\s+/)
        return unless artist.present? && title.present?

        title.chomp!(" Lyrics")

        self.rg_text_format = true if "/#{artist.to_slug}-#{title.to_slug}".downcase == parsed.path.dup.chomp("-lyrics").downcase
      end
    elsif path =~ %r(\A/\d+(\z|/))
      self.annotation_link = true
    end
  end

  def self.parse(link)
    new(link) if link
  end
end
