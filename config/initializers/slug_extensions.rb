class String
  def to_slug
    strip.
    downcase.
    transliterate.
    convert_smart_punctuation.
    convert_misc_characters.
    convert_dollar_signs.
    gsub(/[`'()*,.#´]/, '').
    gsub(/[^a-z0-9\-]+/i, '-').
    gsub(/\-{2,}/, '-').
    gsub(/^\-|\-$/i, '').
    to_s
  end

  def convert_dollar_signs
    gsub(/\s+\$(?=[a-z0-9])/i, ' s')
  end

  def convert_misc_characters
    gsub(/\s+&\s+/, ' and ').
    gsub(/\s+@\s+/, ' at ').
    gsub(/[.]{2,}/, ' ')
    # gsub(/(\d)%(\s|$)/, '\1 percent ')
  end

  def transliterate
    ActiveSupport::Inflector.transliterate(self)
  end
end
