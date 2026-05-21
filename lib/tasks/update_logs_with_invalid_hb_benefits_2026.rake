desc "For logs that fail the validate_housing_universal_credit_matches_income_proportion check created before we released it, clear the answer to the question"
task update_logs_with_invalid_hb_benefits_2026: :environment do
  impacted_logs = LettingsLog.filter_by_year(2026).where(hb: [1, 6], benefits: 3)

  puts "#{impacted_logs.count} logs will be updated #{impacted_logs.map(&:id)}"

  impacted_logs.update!(benefits: nil, hb: nil)

  puts "Done"
end
