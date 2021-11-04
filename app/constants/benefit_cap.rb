module BenefitCap
  @@benefitcap = {
    "Yes - benefit cap" => 5,
    "Yes - removal of the spare room subsidy" => 4,
    "Yes - both the benefit cap and the removal of the spare room subsidy" => 6,
    "No" => 2,
    "Do not know" => 3,
    "Prefer not to say" => 100,
  }

  def self.benefitcap
    @@benefitcap
  end
end
