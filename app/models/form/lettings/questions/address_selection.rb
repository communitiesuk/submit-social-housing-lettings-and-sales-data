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
    answer_opts = { "100" => { "value" => "The address is not listed, I want to enter the address manually" } }
    return answer_opts unless ActiveRecord::Base.connected?
    return answer_opts unless log&.address_options

    answer_opts = {}

    (0...[log.address_options.count, 10].min).each do |i|
      answer_opts[i.to_s] = { "value" => log.address_options[i] }
    end

    answer_opts["divider"] = { "value" => true }
    answer_opts["100"] = { "value" => "The address is not listed, I want to enter the address manually" }
    answer_opts
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user)
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    (log.uprn_known == 1 || log.uprn_confirmed == 1) || !(1..10).cover?(log.address_options&.count)
  end
end
