# monkey patch to allow conversion of array of strings to sentence
class Array
  def to_list
    default_connectors = {
      words_connector:        ', ',
      two_words_connector: ' and ',
      last_word_connector: ', and '
    }
    case self.length
    when 0
      ''
    when 1
      self[0].to_s.dup
    when 2
      "#{self[0]}#{options[:two_words_connector]}#{self[1]}"
    else
      "#{self[0...-1].join(options[:words_connector])}#{options[:last_word_connector]}#{self[-1]}"
    end
  end
end


