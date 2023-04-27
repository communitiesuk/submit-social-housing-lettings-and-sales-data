class Form::Sales::Pages::ExtraBorrowingValueCheck < Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "extra_borrowing_expected_but_not_reported?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.extra_borrowing.title",
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ExtraBorrowingValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[extrabor mortgage deposit value discount]
  end
end
