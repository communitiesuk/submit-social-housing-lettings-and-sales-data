class Form::Lettings::Pages::MinRentValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "min_rent_value_check"
    @depends_on = [{ "rent_in_soft_min_range?" => true }]
    @title_text = { "translation" => "soft_validations.rent.min.title_text", "arguments" => [{ "key" => "brent", "label" => true, "i18n_template" => "brent" }] }
    @informative_text = { "translation" => "soft_validations.rent.min.hint_text", "arguments" => [{ "key" => "soft_min_for_period", "label" => false, "i18n_template" => "soft_min_for_period" }] }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RentValueCheck.new(nil, nil, self)]
  end
end
