class Form::Sales::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this sales log"
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::OwningOrganisation.new(nil, nil, self),
      Form::Sales::Pages::ManagingOrganisation.new(nil, nil, self),
      Form::Sales::Pages::CreatedBy.new(nil, nil, self),
      Form::Sales::Pages::SaleDate.new(nil, nil, self),
      Form::Sales::Pages::PurchaserCode.new(nil, nil, self),
      Form::Sales::Pages::OwnershipScheme.new(nil, nil, self),
      Form::Sales::Pages::SharedOwnershipType.new(nil, nil, self),
      Form::Sales::Pages::DiscountedOwnershipType.new(nil, nil, self),
      Form::Sales::Pages::OutrightOwnershipType.new(nil, nil, self),
      Form::Sales::Pages::BuyerCompany.new(nil, nil, self),
      (Form::Sales::Pages::BuyerLive.new(nil, nil, self) unless form.start_year_2025_or_later?),
      Form::Sales::Pages::JointPurchase.new(nil, nil, self),
      Form::Sales::Pages::NumberJointBuyers.new(nil, nil, self),
      (Form::Sales::Pages::BuyerInterview.new("buyer_interview_joint_purchase", nil, self, joint_purchase: true) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::BuyerInterview.new("buyer_interview", nil, self, joint_purchase: false) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::PrivacyNotice.new("privacy_notice_joint_purchase", nil, self, joint_purchase: true) if form.start_year_2024_or_later?),
      (Form::Sales::Pages::PrivacyNotice.new("privacy_notice", nil, self, joint_purchase: false) if form.start_year_2024_or_later?),
    ].flatten.compact
  end
end
