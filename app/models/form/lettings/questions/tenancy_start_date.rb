class Form::Lettings::Questions::TenancyStartDate < ::Form::Question
  include CollectionTimeHelper

  def initialize(id, hsh, page)
    super
    @id = "startdate"
    @type = "date"
    @unresolved_hint_text = "Some scheme details have changed, and now this log needs updating. Check that the tenancy start date is correct."
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max] if form.start_date.present?
  end

  def date_example_override(log)
    return unless form.start_year_2026_or_later?

    example_date =
      [date_mid_collection_year(log.startdate), Time.zone.today + 7]
        .min
        .to_formatted_s(:govuk_date_number_month)
        .tr(" ", "/")
    I18n.t("forms.#{form.start_date.year}.#{copy_key}.example", default: "", example_date:)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 5, 2024 => 7 }.freeze
end
