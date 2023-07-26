namespace :merge do
  desc "Merge organisations into one"
  task :merge_organisations, %i[absorbing_organisation_id merging_organisation_ids] => :environment do |_task, args|
    absorbing_organisation_id = args[:absorbing_organisation_id]
    merging_organisation_ids = args[:merging_organisation_ids]&.split(",")&.map(&:to_i)

    raise "Usage: rake merge:merge_organisations[absorbing_organisation_id, merging_organisation_ids]" if merging_organisation_ids.blank? || absorbing_organisation_id.blank?

    service = Merge::MergeOrganisationsService.new(absorbing_organisation_id:, merging_organisation_ids:)
    service.call
  end
end
