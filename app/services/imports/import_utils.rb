module Imports
  module ImportUtils
    def field_value(xml_document, namespace, field)
      xml_document.at_xpath("//#{namespace}:#{field}")&.text
    end

    def overridden?(xml_document, namespace, field)
      xml_document.at_xpath("//#{namespace}:#{field}").attributes["override-field"].value
    end

    def to_boolean(input_string)
      input_string == "true"
    end
  end
end
