class Form::Sales::Pages::BuyerLiveInValueCheck < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      {
        "buyer#{person_index}_not_livein?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.buyer#{person_index}_not_livein.title_text",
      "arguments" => [{ "key" => "owhership_scheme", "label" => false, "i18n_template" => "owhership_scheme" }],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerLiveInValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end
end
