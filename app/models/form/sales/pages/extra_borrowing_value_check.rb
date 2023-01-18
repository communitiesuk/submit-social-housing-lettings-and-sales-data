class Form::Sales::Pages::ExtraBorrowingValueCheck < Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "extra_borrowing_expected?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.extra_borrowing.title",
    }
    @informative_text = {
      "translation" => "soft_validations.extra_borrowing.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ExtraBorrowingValueCheck.new(nil, nil, self),
    ]
  end
end
