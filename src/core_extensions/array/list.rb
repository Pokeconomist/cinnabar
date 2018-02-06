# Monkey patch on Array class.
class Array
  # Converts array to list separated by ', ', and last item by ', and'.
  # @return [String] Formatted list of items
  def to_list
    connectors = {
      words:     ', ',
      two_words: ' and ',
      last_word: ', and '
    }
    case self.length
    when 0
      ''
    when 1
      self[0].to_s.dup
    when 2
      "#{self[0]}#{connectors[:two_words]}#{self[1]}"
    else
      "#{self[0...-1].join(connectors[:words])}#{connectors[:last_word]}#{self[-1]}"
    end
  end
end