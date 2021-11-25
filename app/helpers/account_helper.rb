module AccountHelper
  def resource_name
    :user
  end

  def resource
    @resource = current_user
  end
end
