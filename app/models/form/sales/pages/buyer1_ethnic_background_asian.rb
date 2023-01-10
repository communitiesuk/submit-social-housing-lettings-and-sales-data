class Form::Sales::Pages::Buyer1EthnicBackgroundAsian < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_ethnic_background_asian"
    @header = ""
    @subsection = subsection
    @depends_on = [{
      "ethnic_group" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1EthnicBackgroundAsian.new(nil, nil, self),
    ]
  end
end
