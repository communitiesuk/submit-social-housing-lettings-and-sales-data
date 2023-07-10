class DuplicateLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource_by_named_id

  def show
    if @log
      @duplicate_logs = @log.class.duplicate_logs_for_organisation(current_user.organisation_id, @log)
      @all_duplicates = [@log, *@duplicate_logs]
      @duplicate_check_questions = duplicate_check_question_ids.map { |question_id| @log.form.get_question(question_id, @log) }.compact
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
      %w[owning_organisation_id startdate tenancycode postcode_full age1 sex1 ecstat1 tcharge]
    else
      %w[owning_organisation_id saledate purchid age1 sex1 ecstat1 postcode_full]
    end
  end
end
