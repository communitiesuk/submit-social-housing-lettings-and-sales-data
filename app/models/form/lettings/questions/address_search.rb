class Form::Lettings::Questions::AddressSearch < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_search"
    @type = "address_autocomplete"
    @plain_label = true
    @bottom_guidance_partial = "address_search"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options(log = nil, _user = nil)
    return {} unless ActiveRecord::Base.connected?
    return {} unless log&.address_options

    answer_opts = {}

    (0...[log.address_options.count, 10].min).each do |i|
      answer_opts[log.address_options[i][:uprn]] = { "value" => log.address_options[i][:address] }
    end

    answer_opts["divider"] = { "value" => true }
    answer_opts
  end

  def get_extra_check_answer_value(log)
    return unless log.uprn_known == 1

    value = [
      log.address_line1,
      log.address_line2,
      log.town_or_city,
      log.county,
      log.postcode_full,
      (LocalAuthority.find_by(code: log.la)&.name if log.la.present?),
    ].select(&:present?)

    return unless value.any?

    "\n\n#{value.join("\n")}"
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user).transform_values { |value| value["value"] } || {}
  end

  # def hidden_in_check_answers?(log, _current_user = nil)
  #   (log.uprn_known == 1 || log.uprn_confirmed == 1)
  # end

  QUESTION_NUMBER_FROM_YEAR = { 2024 => 12, 2025 => 12 }.freeze
end
