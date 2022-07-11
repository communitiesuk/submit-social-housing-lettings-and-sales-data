class PostcodeService
  def self.clean(postcode)
    postcode.encode("ASCII", "UTF-8", invalid: :replace, undef: :replace, replace: "").delete(" ").upcase
  end
end
