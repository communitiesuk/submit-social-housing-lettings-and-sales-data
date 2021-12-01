module DeviseHelper
  def flash_to_model_errors(resource)
    if flash.alert
      if flash.alert != I18n.t("devise.failure.unauthenticated")
        resource.errors.add :base, flash.alert
      end
      flash.discard
    end
  end
end
