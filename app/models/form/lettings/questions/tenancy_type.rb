class Form::Lettings::Questions::TenancyType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancy"
    @copy_key = "lettings.tenancy_information.tenancy.#{page.id}.tenancy"
    @type = "radio"
    @check_answers_card_number = 0
    @conditional_for = { "tenancyother" => [3] }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def answer_options
    if form.start_year_2024_or_later?
      {
        "4" => {
          "value" => "Assured Shorthold Tenancy (AST) – Fixed term",
          "hint" => "These are mostly provided by housing associations. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
        },
        "6" => {
          "value" => "Secure – fixed term",
          "hint" => "These are mostly provided by local authorities. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
        },
        "2" => {
          "value" => "Assured – lifetime",
        },
        "7" => {
          "value" => "Secure – lifetime",
        },
        "8" => {
          "value" => "Periodic",
          "hint" => "These are rolling tenancies with no fixed end date. They may have an initial fixed term and then become rolling.",
        },
        "5" => {
          "value" => "Licence agreement",
          "hint" => "These are mostly used for Supported Housing and work on a rolling basis.",
        },
        "3" => {
          "value" => "Other",
        },
      }.freeze
    else
      {
        "4" => {
          "value" => "Assured Shorthold Tenancy (AST) – Fixed term",
          "hint" => "Mostly housing associations provide these. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
        },
        "6" => {
          "value" => "Secure – fixed term",
          "hint" => "Mostly local authorities provide these. Fixed term tenancies are intended to be for a set amount of time up to 20 years.",
        },
        "2" => {
          "value" => "Assured – lifetime",
        },
        "7" => {
          "value" => "Secure – lifetime",
        },
        "5" => {
          "value" => "Licence agreement",
          "hint" => "Licence agreements are mostly used for Supported Housing and work on a rolling basis.",
        },
        "3" => {
          "value" => "Other",
        },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 27, 2024 => 27, 2025 => 28, 2026 => 28 }.freeze
end
