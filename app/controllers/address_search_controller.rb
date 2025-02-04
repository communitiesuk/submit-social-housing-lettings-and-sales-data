class AddressSearchController < ApplicationController
  before_action :authenticate_user!

  def index
    query = params[:query]

    if query.match?(/\A\d+\z/) && query.length > 5
      # Query is all numbers and greater than 5 digits, assume it's a UPRN
      service = UprnClient.new(query)
      service.call

      if service.error.present?
        render json: { error: service.error }, status: :unprocessable_entity
      else
        render json: [{ address: service.result["ADDRESS"], uprn: service.result["UPRN"] }]
      end
    elsif query.match?(/[a-zA-Z]/)
      # Query contains letters, assume it's an address
      service = AddressClient.new(query)
      service.call

      if service.error.present?
        render json: { error: service.error }, status: :unprocessable_entity
      else
        render json: service.result.map { |result| { address: result["ADDRESS"], uprn: result["UPRN"] } }
      end
    else
      # Query is ambiguous, use both APIs and merge results
      address_service = AddressClient.new(query)
      uprn_service = UprnClient.new(query)

      address_service.call
      uprn_service.call

      results = (address_service.result || []) + (uprn_service.result || [])

      if address_service.error.present? && uprn_service.error.present?
        render json: { error: "Address and UPRN are not recognised. Check the input." }, status: :unprocessable_entity
      else
        render json: results.map { |result| { address: result["ADDRESS"], uprn: result["UPRN"] } }
      end
    end
  end

  def manual_input
    log = params[:log_type] == "lettings" ? LettingsLog.find(params[:log_id]) : SalesLog.find(params[:log_id])
    log.update!(uprn: nil, uprn_known: 0, uprn_confirmed: nil, address_search: nil)
    redirect_to manual_address_link(log)
  end

  def search_input
    log = params[:log_type] == "lettings" ? LettingsLog.find(params[:log_id]) : SalesLog.find(params[:log_id])
    log.update!(uprn: nil, uprn_known: 0, uprn_confirmed: nil, address_search: nil, address_line1: nil, address_line2: nil, town_or_city: nil, county: nil, postcode_full: nil, is_la_inferred: false, pcode1: nil, pcode2: nil)
    redirect_to search_address_link(log)
  end

  def current
    log_id = params[:log_id]
    sales_log = SalesLog.find_by(id: log_id)
    uprn = sales_log&.address_search

    if uprn.present?
      service = UprnClient.new(uprn)
      service.call

      if service.error.present?
        render json: { error: service.error }, status: :unprocessable_entity
      else
        address = service.result.find { |result| result["UPRN"] == uprn }&.dig("ADDRESS")
        render json: { stored_value: { uprn:, address: } }
      end
    else
      render json: { stored_value: nil }
    end
  end

private

  def manual_address_link(log)
    base_url = send("#{log.log_type}_url", log)
    "#{base_url}/address"
  end

  def search_address_link(log)
    base_url = send("#{log.log_type}_url", log)
    "#{base_url}/address-search"
  end
end
