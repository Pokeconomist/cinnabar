# Monkey patch on String class.
class String
  # Capitalises first letter of each word, and downcases all others.
  #
  # n.b. Capitalisation effective only over ASCII characters.
  # @return [String] Titleised string
  def titleise
    self.downcase.gsub(/\b[a-z]/) { |s| s.capitalize }
  end
end
