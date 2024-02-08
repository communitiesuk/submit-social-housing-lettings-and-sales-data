class UprnAddressSpikeController < ApplicationController
  def show
    if params[:uprn] || params[:address]

      if params[:uprn]
        uprn = params[:uprn]
        service = UprnClient.new(uprn)
        service.call
        if service.error.present?
          @error = "no match"
        else
          @address_returned = UprnDataPresenter.new(service.result)
        end
      elsif params[:address]
        address = params[:address]
        service = AddressClient.new(address)
        service.call
        if service.error.present?
          @error = "no match"
        else
          @addresses_returned = service.result&.map { |r| AddressDataPresenter.new(r) }
        end
      end
    end
    render "content/uprn_address_spike"
  end
end
