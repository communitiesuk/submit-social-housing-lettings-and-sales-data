def filename(klass) = [klass.to_s.underscore, "rb"].join(".")

def write(path, body)
  path = Rails.root.join("app", "models", path)
  puts "#{path}"
  File.write(path, body) unless File.exist?(path)
end
FormHandler.instance.current_lettings_form.sections.each do |section|
  path = filename(section.class)
  write(path, "hi")
end; nil
