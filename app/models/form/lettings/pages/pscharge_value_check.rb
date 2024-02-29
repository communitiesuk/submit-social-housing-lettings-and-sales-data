class Form::Lettings::Pages::PschargeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "pscharge_value_check"
    @depends_on = [{ "pscharge_in_soft_max_range?" => true }]
    @title_text = {
      "translation" => "soft_validations.pscharge.over_soft_max_title",
      "arguments" => [{
        "key" => "pscharge",
        "label" => true,
        "i18n_template" => "pscharge",
      }],
    }
    @informative_text = I18n.t("soft_validations.charges.informative_text")
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PschargeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype pscharge]
  end
end
