class Form::Lettings::Questions::Uprn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn"
    @check_answer_label = "UPRN"
    @header = "Select your address from the list so that we can retrieve its UPRN"
    @type = "radio"
    @answer_options = answer_options
  end

  def answer_options(log = nil, user = nil)
    opts = { "" => "Select an option" }

    return opts unless ActiveRecord::Base.connected?
    return opts unless user
    return opts unless log

    q = log.uprn_query

    return [] unless q

    # TODO: handle non-200 responses
    resp = HTTParty.get("https://api.os.uk/search/places/v1/find?query=#{q}&key=#{ENV['OS_DATA_KEY']}&minmatch=0.8&maxresults=50")
    opts = {}

    resp["results"]&.each do |result|
      uprn = result.dig("DPA", "UPRN")
      address = result.dig("DPA", "ADDRESS")
      opts[uprn] = { "value" => "#{uprn}: #{address}" }
    end

    opts[""] = { "value" => "I can't find my address" }

    opts
  end

  def displayed_answer_options(log, user)
    answer_options(log, user)
  end
end
