class Form::Lettings::Pages::MaxRentValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "max_rent_value_check"
    @depends_on = [{ "rent_in_soft_max_range?" => true }]
    @title_text = {
      "translation" => "soft_validations.rent.max.title_text",
      "arguments" => [{ "key" => "brent", "label" => true, "i18n_template" => "brent" }],
    }
    @informative_text = {
      "translation" => "soft_validations.rent.max.hint_text",
      "arguments" => [
        {
          "key" => "soft_max_for_period",
          "label" => false,
          "i18n_template" => "soft_max_for_period",
        },
      ],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RentValueCheck.new(nil, nil, self)]
  end
end
