# Monkey patch on Array class.
class Array
  # Converts array to comma delimited string, with final item split with ", and ".
  # @return [String] Formatted list of items
  def to_list
    default_connectors = {
      words_connector:     ', ',
      two_words_connector: ' and ',
      last_word_connector: ', and '
    }
    case self.length
    when 0
      ''
    when 1
      self[0].to_s.dup
    when 2
      "#{self[0]}#{default_connectors[:two_words_connector]}#{self[1]}"
    else
      "#{self[0...-1].join(default_connectors[:words_connector])}#{default_connectors[:last_word_connector]}#{self[-1]}"
    end
  end
end