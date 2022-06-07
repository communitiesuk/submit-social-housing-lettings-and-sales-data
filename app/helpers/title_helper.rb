module TitleHelper
  def format_label(count, item)
    count > 1 ? item.pluralize : item
  end

  def format_title(path, searched, page_title, current_user, item_label, count)
    if searched.present?
      title = "#{page_title} (#{count} #{item_label} matching ‘#{searched}’)"
    else
      title = page_title
    end
  end
end
