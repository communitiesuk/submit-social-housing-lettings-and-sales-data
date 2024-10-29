class Form::Lettings::Pages::CareHomeChargesValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_charges_value_check"
    @copy_key = "lettings.soft_validations.carehome_charges_value_check"
    @depends_on = [{ "care_home_charge_expected_not_provided?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::CareHomeChargesValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[chcharge is_carehome]
  end
end
