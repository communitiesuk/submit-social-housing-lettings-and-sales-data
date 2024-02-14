class Form::Lettings::Questions::LettingAllocation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "letting_allocation"
    @check_answer_label = "Allocation system"
    @header = "How was this letting allocated?"
    @type = "checkbox"
    @check_answers_card_number = 0
    @hint_text = "Select all that apply."
    @question_number = 84
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "cbl" => { "value" => "Choice-based lettings (CBL)", "hint" => "Where available vacant properties are advertised and applicants are able to bid for specific properties." },
        "cap" => { "value" => "Common Allocation Policy (CAP)", "hint" => "Where a common system agreed between a group of housing providers is used to determine applicant’s priority for housing." },
        "chr" => { "value" => "Common housing register (CHR)", "hint" => "Where a single waiting list is used by a group of housing providers to receive and process housing applications. Providers may use different approaches to determine priority." },
        "accessible_register" => { "value" => "Accessible housing register", "hint" => "Where the ‘access category’ or another descriptor of whether an available vacant property meets a range of access needs is displayed to applicants during the allocations process." },
        "divider" => { "value" => true },
        "letting_allocation_unknown" => { "value" => "None of these allocation systems" },
      }.freeze
    else
      {
        "cbl" => { "value" => "Choice-based lettings (CBL)" },
        "cap" => { "value" => "Common Allocation Policy (CAP)" },
        "chr" => { "value" => "Common housing register (CHR)" },
        "divider" => { "value" => true },
        "letting_allocation_unknown" => { "value" => "None of these allocation systems" },
      }.freeze
    end
  end
end
