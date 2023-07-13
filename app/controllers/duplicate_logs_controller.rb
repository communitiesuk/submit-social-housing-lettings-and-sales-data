class DuplicateLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource_by_named_id
  before_action :find_duplicate_logs
  before_action :find_original_log_id

  def show
    if @log
      @all_duplicates = [@log, *@duplicate_logs]
      @duplicate_check_questions = duplicate_check_question_ids.map { |question_id|
        question = @log.form.get_question(question_id, @log)
        question if question.page.routed_to?(@log, current_user)
      }.compact
    else
      render_not_found
    end
  end

  def delete_duplicates
    return render_not_found unless @log && @duplicate_logs.any?

    render "logs/delete_duplicates"
  end

private

  def find_resource_by_named_id
    @log = if params[:sales_log_id].present?
             current_user.sales_logs.visible.find_by(id: params[:sales_log_id])
           else
             current_user.lettings_logs.visible.find_by(id: params[:lettings_log_id])
           end
  end

  def find_duplicate_logs
    return unless @log

    @duplicate_logs = if @log.lettings?
                        current_user.lettings_logs.duplicate_logs(@log)
                      else
                        current_user.sales_logs.duplicate_logs(@log)
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

  def find_original_log_id
    query_params = URI.parse(request.url).query
    @original_log_id = CGI.parse(query_params)["original_log_id"][0]&.to_i if query_params.present?
  end
end
