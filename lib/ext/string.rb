class String
  def formatted_postcode
    postcode = upcase.gsub(/\s+/, "")
    case postcode.length
    when 5
      postcode.insert(2, " ")
    when 6
      postcode.insert(3, " ")
    when 7
      postcode.insert(4, " ")
    else
      self
    end
  end
end
