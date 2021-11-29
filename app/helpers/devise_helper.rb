module DeviseHelper
  def flash_to_model_errors(resource)
    if flash.alert
      resource.errors.add :base, flash.alert
      flash.discard
    end
  end
end
