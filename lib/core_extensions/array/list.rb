# monkey patch to allow conversion of array of strings to sentence
class Array
  def to_list
    case self.length
    when 0
      ''
    when 1
      self[0].to_s.dup
    when 2
      "#{self[0]} and #{self[1]}"
    else
      "#{self[0...-1].join(", ")}, and #{self[-1]}"
    end
  end
end


