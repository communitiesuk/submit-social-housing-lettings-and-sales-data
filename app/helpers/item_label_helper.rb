module ItemLabelHelper
  def format_label(count, item)
    count > 1 ? item.pluralize : item
  end
end
