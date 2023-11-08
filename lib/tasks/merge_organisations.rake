namespace :merge do
  desc "Merge organisations into an existing organisation"
  task :merge_organisations, %i[absorbing_organisation_id merging_organisation_ids merge_date] => :environment do |_task, args|
    absorbing_organisation_id = args[:absorbing_organisation_id]
    merging_organisation_ids = args[:merging_organisation_ids]&.split(" ")&.map(&:to_i)
    begin
      merge_date = args[:merge_date].present? ? Date.parse(args[:merge_date]) : nil
    rescue StandardError
      raise "Usage: rake merge:merge_organisations[absorbing_organisation_id, merging_organisation_ids, merge_date]. Merge date must be in format YYYY-MM-DD"
    end

    if merging_organisation_ids.blank? || absorbing_organisation_id.blank?
      raise "Usage: rake merge:merge_organisations[absorbing_organisation_id, merging_organisation_ids, merge_date]"
    end

    service = Merge::MergeOrganisationsService.new(absorbing_organisation_id:, merging_organisation_ids:, merge_date:)
    service.call
  end

  desc "Merge organisations into an existing organisation, make the absorbing organisation active from merge date only"
  task :merge_organisations_into_new_organisation, %i[absorbing_organisation_id merging_organisation_ids merge_date] => :environment do |_task, args|
    absorbing_organisation_id = args[:absorbing_organisation_id]
    merging_organisation_ids = args[:merging_organisation_ids]&.split(" ")&.map(&:to_i)
    begin
      merge_date = args[:merge_date].present? ? Date.parse(args[:merge_date]) : nil
    rescue StandardError
      raise "Usage: rake merge:merge_organisations_into_new_organisation[absorbing_organisation_id, merging_organisation_ids, merge_date]. Merge date must be in format YYYY-MM-DD"
    end

    if merging_organisation_ids.blank? || absorbing_organisation_id.blank?
      raise "Usage: rake merge:merge_organisations_into_new_organisation[absorbing_organisation_id, merging_organisation_ids, merge_date]"
    end

    service = Merge::MergeOrganisationsService.new(absorbing_organisation_id:, merging_organisation_ids:, merge_date:, absorbing_organisation_active_from_merge_date: true)
    service.call
  end
end
