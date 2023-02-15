class Form::Sales::Pages::Buyer2EthnicBackgroundAsian < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_background_asian"
    @depends_on = [{
      "ethnic_group2" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2EthnicBackgroundAsian.new(nil, nil, self),
    ]
  end
end
