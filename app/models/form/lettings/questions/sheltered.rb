class Form::Lettings::Questions::Sheltered < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sheltered"
    @check_answer_label = "Is this letting in sheltered accommodation?"
    @header = "Is this letting in sheltered accommodation?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "Sheltered housing and special retirement housing are for tenants with low-level care and support needs. This typically provides some limited support to enable independent living, such as alarm-based assistance or a scheme manager.</br></br>Extra care housing is for tenants with medium to high care and support needs, often with 24 hour access to support staff provided by an agency registered with the Care Quality Commission."
    @question_number = 29
  end

  def answer_options
    if form.start_year_after_2024?
      { "1" => { "value" => "Yes – specialist retirement housing" },
        "2" => { "value" => "Yes – extra care housing" },
        "5" => { "value" => "Yes – sheltered housing for adults aged under 55 years" },
        "6" => { "value" => "Yes – sheltered housing for adults aged 55 years and over who are not retired" },
        "3" => { "value" => "No" },
        "divider" => { "value" => true },
        "4" => { "value" => "Don’t know" } }
    else
      { "2" => { "value" => "Yes – extra care housing" },
        "1" => { "value" => "Yes – specialist retirement housing" },
        "5" => { "value" => "Yes – sheltered housing for adults aged under 55 years" },
        "3" => { "value" => "No" },
        "divider" => { "value" => true },
        "4" => { "value" => "Don’t know" } }
    end
  end
end
