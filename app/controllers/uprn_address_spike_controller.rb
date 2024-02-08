class UprnAddressSpikeController < ApplicationController
  def show
    if params[:uprn] || params[:address]

      if params[:uprn].present?
        uprn = params[:uprn]
        service = UprnClient.new(uprn)
        service.call
        if service.error.present?
          @error = "No match"
        else
          @address_returned = UprnDataPresenter.new(service.result)
        end
      elsif params.values_at(:address_line1, :address_line2, :town_or_city, :postcode).any?(&:present?)
        @address_given = params.values_at(:address_line1, :address_line2, :town_or_city, :postcode).reject { |item| item == "" }.join(", ")
        service = AddressClient.new(@address_given)
        service.call
        if service.error.present?
          @error = "No matches"
        else
          @addresses_returned = service.result&.map { |r| AddressDataPresenter.new(r) }
        end
      end
    end
    render "content/uprn_address_spike"
  end
end
