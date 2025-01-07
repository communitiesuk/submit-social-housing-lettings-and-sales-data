class AddressOptionsController < ApplicationController
  def index
    query = params[:query]
    service = AddressClient.new(address: query)
    service.call

    if service.error.present?
      render json: { error: service.error }, status: :unprocessable_entity
    else
      render json: service.result.map { |result| { address: result["ADDRESS"], uprn: result["UPRN"] } }
    end
  end

  def current
    log_id = params[:log_id]
    sales_log = SalesLog.find_by(id: log_id)
    uprn = sales_log&.address_search

    if uprn.present?
      service = AddressClient.new(uprn: uprn)
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
