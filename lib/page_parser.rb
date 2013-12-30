class PageParser
  def initialize(body)
    @body = body
  end

  def parse_and_find_rg_links
    aggregates = {count_of_links_to_rg_song_pages: 0,
                  count_of_links_with_text_ending_in_lyrics: 0,
                  count_of_links_with_rg_format: 0,
                  count_of_annotation_links: 0}
    links_to_rg = {}

    doc = Nokogiri::HTML.fragment(body)
    doc.css('a').each do |link|
      parsed = ParsedLink.parse(link)
      next unless parsed.rg_link?

      links_to_rg[parsed.inner_text] = parsed.href
      aggregates[:count_of_links_to_rg_song_pages] += 1 if parsed.song_page_link?
      aggregates[:count_of_links_with_text_ending_in_lyrics] += 1 if parsed.lyrics_text_link?
      aggregates[:count_of_links_with_rg_format] += 1 if parsed.rg_text_format?
      aggregates[:count_of_annotation_links] += 1 if parsed.annotation_link?
    end

    {links: links_to_rg,
     total_links_to_rg: links_to_rg.count}.merge(aggregates).merge(identify_link_clumps)
  end

  private
  attr_reader :body

  def identify_link_clumps
    link_clumps_by_rg_text_format = identify_link_clumps_with(:rg_text_format?)
    link_clumps_fuzzy_match = identify_link_clumps_with(:lyrics_text_link?)

    {count_of_link_clumps: link_clumps_by_rg_text_format[:count],
     largest_link_clump_size: link_clumps_by_rg_text_format[:largest],
     count_of_link_clumps_fuzzy_match: link_clumps_fuzzy_match[:count],
     largest_link_clump_size_fuzzy_match: link_clumps_fuzzy_match[:largest]}
  end

  def adjacent_rg_text_format_link(link, method)
    return unless next_link = next_anchor_sibling(link)
    next_link['data-seen-already'] = true
    next_link if ParsedLink.parse(next_link).try(method)
  end

  def identify_link_clumps_with(method)
    largest_clump_size, current_clump_size, number_of_clumps = 0, 0, 0

    doc = Nokogiri::HTML.fragment(body)

    while link = doc.css('a:not([data-seen-already])').first
      link['data-seen-already'] = 'true'

      parsed = ParsedLink.parse(link)
      next unless parsed.try(method)

      current_clump_size = 1

      current_link = link
      while current_link = adjacent_rg_text_format_link(current_link, method)
        current_clump_size += 1
      end

      if current_clump_size > 1
        number_of_clumps += 1
        largest_clump_size = current_clump_size if current_clump_size > largest_clump_size
      end
    end

    {count: number_of_clumps, largest: largest_clump_size}
  end

  def next_anchor_sibling(node)
    sibling = node.next_sibling
    sibling = sibling.next_sibling while sibling.try(:name).to_s == 'br'

    sibling if sibling.try(:name) == 'a'
  end
end
