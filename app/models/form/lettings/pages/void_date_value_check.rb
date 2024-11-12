class Form::Lettings::Pages::VoidDateValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "void_date_value_check"
    @copy_key = "lettings.soft_validations.void_date_value_check"
    @depends_on = [{ "voiddate_in_soft_range?" => true }]
    @title_text = { "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text" }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::VoidDateValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[voiddate startdate]
  end
end
