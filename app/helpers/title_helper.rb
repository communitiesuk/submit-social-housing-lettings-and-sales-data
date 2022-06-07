module TitleHelper
  def format_label(count, item)
    count > 1 ? item.pluralize : item
  end

  def format_title(searched, page_title, current_user, item_label, count, organisation_name)
    if searched.present?
      actual_title = support_user_sab_nav?(current_user, organisation_name) ? organisation_name : page_title
      "#{actual_title} (#{count} #{item_label} matching ‘#{searched}’)"
    else
      support_user_sab_nav?(current_user, organisation_name) ? "#{organisation_name} (#{page_title})" : page_title
    end
  end

private

  def support_user_sab_nav?(current_user, organisation_name)
    current_user.support? && organisation_name
  end
end
