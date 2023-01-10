class Form::Sales::Sections::SaleInformation < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "sale_information"
    @label = "Sale information"
    @description = ""
    @subsections = [
      Form::Sales::Subsections::SharedOwnershipScheme.new(nil, nil, self),
      Form::Sales::Subsections::DiscountedOwnershipScheme.new(nil, nil, self),
      Form::Sales::Subsections::OutrightSale.new(nil, nil, self),
    ] || []
  end
end
