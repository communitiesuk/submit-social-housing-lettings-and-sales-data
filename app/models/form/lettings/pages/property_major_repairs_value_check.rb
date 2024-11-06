class Form::Lettings::Pages::PropertyMajorRepairsValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_major_repairs_value_check"
    @copy_key = "lettings.soft_validations.major_repairs_date_value_check"
    @depends_on = [{ "major_repairs_date_in_soft_range?" => true }]
    @title_text = { "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text" }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::MajorRepairsDateValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[mrcdate startdate]
  end
end
