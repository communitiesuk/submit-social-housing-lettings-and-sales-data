module ContentHelper
  def render_content_page(page_name, page_title: nil, locals: {})
    raw_content = File.read("app/views/content/#{page_name}.md")
    content_with_erb_tags_replaced = ApplicationController.renderer.render(
      inline: raw_content,
      locals: locals
    )

    @page_title = page_title || page_name.to_s.humanize
    @page_content = GovukMarkdown.render(content_with_erb_tags_replaced).html_safe

    render "content/page"
  end
end
