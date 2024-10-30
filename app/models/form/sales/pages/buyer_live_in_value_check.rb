class Form::Sales::Pages::BuyerLiveInValueCheck < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      {
        "buyer#{person_index}_livein_wrong_for_ownership_type?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.buyer_livein_value_check.buyer#{person_index}"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [{ "key" => "ownership_scheme", "label" => false, "i18n_template" => "ownership_scheme" }],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [{ "key" => "ownership_scheme", "label" => false, "i18n_template" => "ownership_scheme" }],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerLiveInValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end

  def interruption_screen_question_ids
    ["ownershipsch", "buy#{@person_index}livein"]
  end
end
