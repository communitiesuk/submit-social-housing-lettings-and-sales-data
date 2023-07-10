class DuplicateLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource_by_named_id

  def show
    if @log
      @duplicate_logs = if @log.lettings?
                          current_user.lettings_logs.duplicate_logs(@log)
                        else
                          current_user.sales_logs.duplicate_logs(@log)
                        end
      @all_duplicates = [@log, *@duplicate_logs]
      @duplicate_check_questions = duplicate_check_question_ids.map { |question_id|
        question = @log.form.get_question(question_id, @log)
        question if question.page.routed_to?(@log, current_user)
      }.compact
    else
      render_not_found
    end
  end

private

  def find_resource_by_named_id
    @log = if params[:sales_log_id].present?
             current_user.sales_logs.visible.find_by(id: params[:sales_log_id])
           else
             current_user.lettings_logs.visible.find_by(id: params[:lettings_log_id])
           end
  end

  def duplicate_check_question_ids
    if @log.lettings?
      ["owning_organisation_id",
       "startdate",
       "tenancycode",
       "postcode_full",
       "scheme_id",
       "location_id",
       "age1",
       "sex1",
       "ecstat1",
       @log.household_charge == 1 ? "household_charge" : nil,
       "tcharge",
       @log.is_carehome? ? "chcharge" : nil].compact
    else
      %w[owning_organisation_id saledate purchid age1 sex1 ecstat1 postcode_full]
    end
  end

private

  def find_resource_by_named_id
    @log = if params[:sales_log_id].present?
             current_user.sales_logs.visible.find_by(id: params[:sales_log_id])
           else
             current_user.lettings_logs.visible.find_by(id: params[:lettings_log_id])
           end
  end
end
