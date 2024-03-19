class Form::Lettings::Pages::MultiplePartnersValueCheck < Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "multiple_partners?" => true,
      },
    ]
    @person_index = person_index
    @title_text = {
      "translation" => "soft_validations.multiple_partners_lettings.title",
      "arguments" => [],
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::MultiplePartnersValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end

  def interruption_screen_question_ids
    %w[relat2 relat3 relat4 relat5 relat6 relat7 relat8]
  end
end
