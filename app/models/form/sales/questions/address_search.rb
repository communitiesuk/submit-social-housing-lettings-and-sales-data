class Form::Sales::Questions::AddressSearch < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_search"
    @copy_key = "sales.property_information.address_search"
    @error_label = "Enter search query"
    @type = "address_autocomplete"
    @plain_label = true
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

  def displayed_answer_options(log, user = nil)
    answer_options(log, user).transform_values { |value| value["value"] } || {}
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    (log.uprn_known == 1 || log.uprn_confirmed == 1)
  end
end
