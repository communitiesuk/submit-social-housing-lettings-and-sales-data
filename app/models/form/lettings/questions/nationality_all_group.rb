class Form::Lettings::Questions::NationalityAllGroup < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "nationality_all_group"
    @check_answer_label = "Lead tenant’s nationality"
    @header = "What is the nationality of the lead tenant?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest. If the lead tenant is a dual national of the United Kingdom and another country, enter United Kingdom. If they are a dual national of two other countries, the tenant should decide which country to enter."
    @answer_options = ANSWER_OPTIONS
    @question_number = 36
    @conditional_for = { "nationality_all" => [12] }
    @hidden_in_check_answers = { "depends_on" => [{ "nationality_all_group" => 12 }] }
  end

  ANSWER_OPTIONS = {
    "826" => { "value" => "United Kingdom" },
    "12" => { "value" => "Other" },
    "0" => { "value" => "Tenant prefers not to say" },
  }.freeze
end
