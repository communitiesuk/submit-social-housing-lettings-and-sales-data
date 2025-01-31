class AddressOptionsController < ApplicationController
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
end
