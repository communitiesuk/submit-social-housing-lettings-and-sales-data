class MergeController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_scope!

  def show
    render form.view_path
  end

  def update
    if form.valid? && form.save!
      redirect_to form.next_path
    else
      render form.view_path
    end
  end

  def organisations
    @answer_options = answer_options
    @merge = Merge.new(form_params)
    @merging_organisations_list = Organisation.where(id: @merge.merging_organisations)
    @organisation = Organisation.find(params[:id])
  end

  def answer_options
    answer_options = { "" => "Select an option" }

    Organisation.all.pluck(:id, :name).each do |organisation|
      answer_options[organisation[0]] = organisation[1]
    end
    answer_options
  end

private

  def form_params
    merge_params = params.fetch(:merge, {}).permit(:merging_organisations)
    merge_params[:merging_organisations] = if merge_params[:merging_organisations].blank?
                                             [params[:id]]
                                           else
                                             merge_params[:merging_organisations].split(" ") << params[:merge][:merging_organisation]
                                           end
    merge_params
  end

  def authenticate_scope!
    if current_user.organisation != Organisation.find(params[:id]) && !current_user.support?
      render_not_found
    end
  end
end
