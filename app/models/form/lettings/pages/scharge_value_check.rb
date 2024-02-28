class Form::Lettings::Pages::SchargeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "scharge_value_check"
    @depends_on = [{ "scharge_in_soft_max_range?" => true }]
    @title_text = {
      "translation" => "soft_validations.scharge.over_soft_max_title",
      "arguments" => [{
        "key" => "scharge",
        "label" => true,
        "i18n_template" => "scharge",
      }],
    }
    @informative_text = I18n.t("soft_validations.charges.informative_text")
  end

  def questions
    @questions ||= [Form::Lettings::Questions::SchargeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype scharge]
  end
end
