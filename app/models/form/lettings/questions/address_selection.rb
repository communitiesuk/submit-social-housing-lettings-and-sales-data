class Form::Lettings::Questions::AddressSelection < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "address_selection"
    @header = "Select the correct address"
    @type = "radio"
    @check_answer_label = "Select the correct address"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true # have just added this, check if it works!
  end

  def answer_options(log = nil, user = nil)
    answer_opts = {
      # "0" => { "value" => "address 0" },
      # "1" => { "value" => "address 1" },
      # "2" => { "value" => "address 2" },
      # "3" => { "value" => "address 3" },
      # "4" => { "value" => "address 4" },
      # "5" => { "value" => "address 5" },
      # "6" => { "value" => "address 6" },
      # "7" => { "value" => "address 7" },
      # "8" => { "value" => "address 8" },
      # "9" => { "value" => "address 9" },
    }
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
    }.freeze
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user)
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    log.uprn_known == 1 || log.uprn_confirmed == 1
  end

private

  def selected_answer_option_is_derived?(_log)
    true
  end
end
