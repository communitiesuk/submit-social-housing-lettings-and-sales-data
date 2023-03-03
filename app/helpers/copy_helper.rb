module CopyHelper
  def translate(key, pluralise_condition: false)
    I18n.t(key, count: pluralise_condition ? 2 : 1)
  end
end
