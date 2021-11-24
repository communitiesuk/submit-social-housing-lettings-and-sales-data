class SoftValidationsController < ApplicationController
  def show
    @case_log = CaseLog.find(params[:case_log_id])
    page_id = request.env["PATH_INFO"].split("/")[-2]
    form = FormHandler.instance.get_form("2021_2022")
    page = form.get_page(page_id)
    if page_requires_soft_validation_override?(page)
      errors = @case_log.soft_errors.values.first
      render json: { show: true, label: errors.message, hint: errors.hint_text }
    else
      render json: { show: false }
    end
  end

private

  def page_requires_soft_validation_override?(page)
    @case_log.soft_errors.present? && @case_log.soft_errors.keys.first == page.soft_validations&.first&.id
  end
end
