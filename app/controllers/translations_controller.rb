class TranslationsController < ApplicationController
  def index
    @translation_overrides = Translation.all

    committed_translations = YAML.load_file("config/locales/forms/questions/2024/en.yml")
    @default_translations = flatten(committed_translations["en"]).to_a
    render "translations/index"
  end
end

private

def flatten(translation_hash)
  translation_hash.each_with_object({}) do |(k, v), h|
    if v.is_a? Hash
      flatten(v).map do |h_k, h_v|
        h["#{k}.#{h_k}".to_sym] = h_v
      end
    else
      h[k] = v
    end
  end
end
