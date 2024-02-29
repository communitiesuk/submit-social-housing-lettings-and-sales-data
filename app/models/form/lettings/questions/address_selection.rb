class Form::Lettings::Questions::AddressSelection < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_selection"
    @header = "Select the correct address"
    @type = "radio"
    @check_answer_label = "Select the correct address"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def answer_options(log = nil, _user = nil)
    answer_opts = { "10" => { "value" => "The address is not listed" } }
    return answer_opts unless ActiveRecord::Base.connected?
    return answer_opts unless log
    return answer_opts unless log.address_options

    values = []
    log.address_options.each do |option|
      values.append(option)
    end

    {
      "0" => { "value" => values[0] },
      "1" => { "value" => values[1] },
      "2" => { "value" => values[2] },
      "3" => { "value" => values[3] },
      "4" => { "value" => values[4] },
      "5" => { "value" => values[5] },
      "6" => { "value" => values[6] },
      "7" => { "value" => values[7] },
      "8" => { "value" => values[8] },
      "9" => { "value" => values[9] },
      "divider" => { "value" => true },
      "10" => { "value" => "The address is not listed, I want to enter the address manually" },
    }.freeze
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user)
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    (log.uprn_known == 1 || log.uprn_confirmed == 1)
  end
end
