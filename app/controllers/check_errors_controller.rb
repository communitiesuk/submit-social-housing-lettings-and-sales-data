class CheckErrorsController < ApplicationController
  include DuplicateLogsHelper

  before_action :authenticate_user!
  before_action :find_resource_by_named_id

  def confirm_clear_answer
    return render_not_found unless @log

    @related_question_ids = params[@log.model_name.param_key].keys.reject { |id| id == "page_id" }
    question_id = @related_question_ids.find { |id| !params[id].nil? }
    @question = @log.form.get_question(question_id, @log)
    @page = @log.form.get_page(params[@log.model_name.param_key]["page_id"])
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

# def restore_error_field_values(questions)
#   return unless questions

#   questions.each do |question|
#     if question&.type == "date" && @log.attributes.key?(question.id)
#       @log[question.id] = @log.send("#{question.id}_was")
#     end
#   end
# end

def responses_for_page(page)
  page.questions.each_with_object({}) do |question, result|
    question_params = params[@log.model_name.param_key][question.id]
    if question.type == "date"
      day = params[@log.model_name.param_key]["#{question.id}(3i)"]
      month = params[@log.model_name.param_key]["#{question.id}(2i)"]
      year = params[@log.model_name.param_key]["#{question.id}(1i)"]
      next unless [day, month, year].any?(&:present?)

      result[question.id] = if Date.valid_date?(year.to_i, month.to_i, day.to_i) && year.to_i.positive?
                              Date.new(year.to_i, month.to_i, day.to_i)
                            else
                              Date.new(0, 1, 1)
                            end
    end

    if question.id == "saledate" && set_managing_organisation_to_assigned_to_organisation?(result["saledate"])
      result["managing_organisation_id"] = @log.assigned_to.organisation_id
    end

    next unless question_params

    if %w[checkbox validation_override].include?(question.type)
      question.answer_keys_without_dividers.each do |option|
        result[option] = question_params.include?(option) ? 1 : 0
      end
    else
      result[question.id] = question_params
    end

    if question.id == "owning_organisation_id"
      owning_organisation = result["owning_organisation_id"].present? ? Organisation.find(result["owning_organisation_id"]) : nil

      result["managing_organisation_id"] = owning_organisation.id if set_managing_organisation_to_owning_organisation?(owning_organisation)
    end

    result
  end
end
