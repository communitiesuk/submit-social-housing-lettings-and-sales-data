class Form::Lettings::Pages::PreviousPostcode < ::Form::Page
  def initialize(id, hsh, page)
    super
    @depends_on = [{ "renewal" => 0 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Ppcodenk.new(nil, nil, self),
      Form::Lettings::Questions::PpostcodeFull.new(nil, nil, self),
    ]
  end
end
