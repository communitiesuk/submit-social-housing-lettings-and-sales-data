class DuplicateLogsController < ApplicationController
  include DuplicateLogsHelper

  before_action :authenticate_user!
  before_action :find_resource_by_named_id
  before_action :find_duplicates_for_a_log
  before_action :find_original_log
  before_action :find_organisation, only: [:index]
  before_action :find_all_duplicates, only: [:index]

  def show
    if @log
      @all_duplicates = [@log, *@duplicate_logs]
    else
      render_not_found
    end
  end

  def delete_duplicates
    return render_not_found unless @log && @duplicate_logs.any?

    render "logs/delete_duplicates"
  end

  def index
    @duplicate_sets_count = @duplicates[:lettings].count + @duplicates[:sales].count
    render "duplicate_logs/no_more_duplicates" if @duplicate_sets_count.zero?
  end

private

  def find_resource_by_named_id
    @log = if params[:sales_log_id].present?
             current_user.sales_logs.visible.find_by(id: params[:sales_log_id])
           else
             current_user.lettings_logs.visible.find_by(id: params[:lettings_log_id])
           end
  end

  def find_duplicates_for_a_log
    return unless @log

    @duplicate_logs = if @log.lettings?
                        current_user.lettings_logs.duplicate_logs(@log)
                      else
                        current_user.sales_logs.duplicate_logs(@log)
                      end
  end

  def find_all_duplicates
    return @duplicates = duplicates_for_user(current_user) if current_user.data_provider?

    return unless @organisation

    @duplicates = duplicates_for_organisation(@organisation)
  end

  def find_original_log
    query_params = URI.parse(request.url).query
    original_log_id = CGI.parse(query_params)["original_log_id"][0]&.to_i if query_params.present?
    @original_log = if params[:sales_log_id].present?
                      current_user.sales_logs.find_by(id: original_log_id)
                    else
                      current_user.lettings_logs.find_by(id: original_log_id)
                    end
  end

  def find_organisation
    @organisation = current_user.support? ? Organisation.find(params[:organisation_id]) : current_user.organisation
  end
end
