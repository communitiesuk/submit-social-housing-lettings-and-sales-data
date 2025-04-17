class OrganisationNameChangesController < ApplicationController
  before_action :set_organisation, only: %i[create change_name]
  before_action :set_previous_name_changes, only: %i[create change_name]

  def create
    @organisation_name_change = @organisation.organisation_name_changes.new(organisation_name_change_params)

    if @organisation_name_change.save
      notice_message = @organisation_name_change.immediate_change ? "Name change saved successfully." : "Name change scheduled for #{@organisation_name_change.formatted_startdate}."
      redirect_to organisation_path(@organisation), notice: notice_message
    else
      render :new, status: :unprocessable_entity
    end
  end

  def change_name
    @organisation_name_change = OrganisationNameChange.new
    render :new, layout: "application"
  end

  def cancel_confirmation
    @organisation_name_change = OrganisationNameChange.find(params[:change_id])
    render :cancel_confirmation, layout: "application"
  end

  def cancel
    @organisation_name_change = OrganisationNameChange.find(params[:change_id])
    if @organisation_name_change.update_column(:discarded_at, Time.zone.today)
      redirect_to organisation_path(@organisation_name_change.organisation), notice: "The scheduled name change has been successfully cancelled."
    else
      redirect_to organisation_path(@organisation_name_change.organisation), notice: "Failed to cancel the scheduled name change."
    end
  end

private

  def set_organisation
    @organisation = Organisation.find(params[:id])
  end

  def set_previous_name_changes
    @previous_name_changes = @organisation.name_changes_with_dates
  end

  def organisation_name_change_params
    params.require(:organisation_name_change).permit(:name, :startdate, :immediate_change).tap do |whitelisted|
      whitelisted[:immediate_change] = ActiveModel::Type::Boolean.new.cast(whitelisted[:immediate_change])
    end
  end
end
