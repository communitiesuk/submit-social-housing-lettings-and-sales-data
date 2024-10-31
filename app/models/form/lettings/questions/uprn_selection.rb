class Form::Lettings::Questions::UprnSelection < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn_selection"
    @type = "radio"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def answer_options(log = nil, _user = nil)
    answer_opts = { "uprn_not_listed" => { "value" => "The address is not listed, I want to enter the address manually" } }
    return answer_opts unless ActiveRecord::Base.connected?
    return answer_opts unless log&.address_options

    answer_opts = {}

    (0...[log.address_options.count, 10].min).each do |i|
      answer_opts[log.address_options[i][:uprn]] = { "value" => log.address_options[i][:address] }
    end

    answer_opts["divider"] = { "value" => true }
    answer_opts["uprn_not_listed"] = { "value" => "The address is not listed, I want to enter the address manually" }
    answer_opts
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user)
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    (log.uprn_known == 1 || log.uprn_confirmed == 1) || !(1..10).cover?(log.address_options&.count)
  end

  def input_playback(log = nil)
    return unless log&.address_line1_input || log&.postcode_full_input

    address_options_count = answer_options(log).count > 1 ? answer_options(log).count - 2 : 0
    searched_address = [log.address_line1_input, log.postcode_full_input].select(&:present?).map { |x| "<strong>#{x}</strong>" }.join(" and ")
    "#{address_options_count} #{'address'.pluralize(address_options_count)} found for #{searched_address}. <a href=\"#{page.skip_href(log)}\">Search again</a>".html_safe
  end
end
