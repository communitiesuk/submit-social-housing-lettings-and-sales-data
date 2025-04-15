class OrganisationNameChangesController < ApplicationController
  before_action :set_organisation, only: %i[create change_name]
  before_action :set_previous_name_changes, only: %i[create change_name]

  def create
    @organisation_name_change = @organisation.organisation_name_changes.new(organisation_name_change_params)
    @organisation_name_change.change_type = :user_change

    if @organisation_name_change.save
      notice_message = @organisation_name_change.immediate_change ? "Name change saved successfully." : "Name change scheduled for #{@organisation_name_change.formatted_change_date}."
      redirect_to organisation_path(@organisation), notice: notice_message
    else
      render :new, status: :unprocessable_entity
    end
  end

  def change_name
    @organisation_name_change = OrganisationNameChange.new
    render :new, layout: "application"
  end

private

  def set_organisation
    @organisation = Organisation.find(params[:id])
  end

  def set_previous_name_changes
    @previous_name_changes = @organisation.name_changes_with_dates
  end

  def organisation_name_change_params
    params.require(:organisation_name_change).permit(:name, :change_date, :immediate_change)
  end
end
