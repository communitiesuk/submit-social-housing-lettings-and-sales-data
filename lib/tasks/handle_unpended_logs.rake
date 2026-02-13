desc "Deduplicates logs where we have inadvertently turned some pending logs to in progress / completed"
task :handle_unpended_logs, %i[perform_updates] => :environment do |_task, args|
  dry_run = args[:perform_updates].blank? || args[:perform_updates] != "true"

  pg = ActiveRecord::Base.connection
  query = "SELECT \"versions\".* FROM \"versions\" WHERE \"versions\".\"item_type\" = 'LettingsLog' AND whodunnit is null AND ((object_changes like '%status:\n- 3\n- 1%') OR (object_changes like '%status:\n- 3\n- 2%'))"
  results = pg.execute(query)

  duplicate_log_attributes = %w[owning_organisation_id tenancycode startdate age1_known age1 sex1 sexrab1 ecstat1 tcharge household_charge chcharge]

  seen = [].to_set

  output = CSV.generate(headers: true) do |csv|
    csv << ["Log ID", "Collection Year", "Current Status", "Owning Org", "Owner Id", "Owner Email", "Outcome", "Reason"]
    results.each do |result|
      next if result["object_changes"].count("\n") <= 7 && result["object_changes"].include?("status:\n- 3\n- 2")

      id = YAML.safe_load(result["object"], permitted_classes: [Time, BigDecimal])["id"]
      next if seen.include?(id)

      log = LettingsLog.find(id)

      if log.updated_at != result["created_at"]
        has_been_manually_updated = false
        v = log.versions.last
        while !has_been_manually_updated && v.created_at != result["created_at"]
          if !v.whodunnit.nil?
            has_been_manually_updated = true
          else
            v = v.previous
          end
        end

        if has_been_manually_updated
          seen.add(id)
          csv << [id, log.collection_start_year, log.status, log.owning_organisation_name, log.assigned_to_id, log.assigned_to.email, "Leave", "Log updated in UI"]
          next
        end
      end

      # This is the normal query for duplicates but without the check that the logs are visible (i.e. not deleted/pending)
      duplicates = LettingsLog.where.not(id: log.id)
                              .where.not(startdate: nil)
                              .where.not(sex1: nil)
                              .where.not(ecstat1: nil)
                              .where.not(needstype: nil)
                              .age1_answered
                              .tcharge_answered
                              .chcharge_answered
                              .location_for_log_answered_as(log)
                              .address_for_log_answered_as(log)
                              .where(log.slice(*duplicate_log_attributes))

      duplicate_count = duplicates.length

      if duplicate_count.zero?
        seen.add(id)
        csv << [id, log.collection_start_year, log.status, log.owning_organisation_name, log.assigned_to_id, log.assigned_to.email, "Leave", "Log has no duplicates"]
        next
      end

      visible_duplicates = duplicates.where(status: %w[in_progress completed])
      deleted_duplicates = duplicates.where(status: %w[deleted])

      if visible_duplicates.length.zero? && deleted_duplicates.any? { |dup| dup.discarded_at > result["created_at"] }
        seen.add(id)
        csv << [id, log.collection_start_year, log.status, log.owning_organisation_name, log.assigned_to_id, log.assigned_to.email, "Leave", "Log has no visible duplicates and at least one duplicate has been deleted since being affected"]
        next
      end

      if visible_duplicates.length.zero?
        seen.add(id)
        csv << [id, log.collection_start_year, log.status, log.owning_organisation_name, log.assigned_to_id, log.assigned_to.email, "Leave", "Log has no visible duplicates"]
        next
      end

      unaffected_duplicates = []
      affected_updated_duplicates = []
      affected_non_updated_duplicates = [log]
      visible_duplicates.each do |dup|
        vquery = "SELECT \"versions\".* FROM \"versions\" WHERE \"versions\".\"item_type\" = 'LettingsLog' AND \"versions\".\"item_id\" = #{dup.id} AND whodunnit is null AND ((object_changes like '%status:\n- 3\n- 1%') OR (object_changes like '%status:\n- 3\n- 2%'))"
        res = pg.execute(vquery)

        if res.count.zero?
          unaffected_duplicates.push(dup)
        elsif res[0]["object_changes"].count("\n") <= 7 && res[0]["object_changes"].include?("status:\n- 3\n- 2")
          unaffected_duplicates.push(dup)
        else
          has_been_manually_updated = false
          v = dup.versions.last
          while !has_been_manually_updated && v.created_at != res[0]["created_at"]
            if !v.whodunnit.nil?
              has_been_manually_updated = true
            else
              v = v.previous
            end
          end

          if has_been_manually_updated
            affected_updated_duplicates.push(dup)
          else
            affected_non_updated_duplicates.push(dup)
          end
        end
      end

      unless unaffected_duplicates.empty?
        unaffected_logs_reference = "log#{unaffected_duplicates.length > 1 ? 's' : ''} #{unaffected_duplicates.map(&:id).join(', ')}"
        affected_updated_duplicates.each do |d|
          unless seen.include?(d.id)
            seen.add(d.id)
            csv << [d.id, d.collection_start_year, d.status, d.owning_organisation_name, d.assigned_to_id, d.assigned_to.email, "Leave", "Log updated in UI"]
          end
        end
        affected_non_updated_duplicates.each do |d|
          seen.add(d.id)
          csv << [d.id, d.collection_start_year, d.status, d.owning_organisation_name, d.assigned_to_id, d.assigned_to.email, "Delete", "Log is a duplicate of unaffected log(s)", unaffected_logs_reference]
          # rubocop:disable Style/Next
          unless dry_run
            d.discarded_at = Time.zone.now
            d.status = "deleted"
            d.save!(validate: false)
          end
        end
        next
      end

      unless affected_updated_duplicates.empty?
        updated_logs_reference = "log#{affected_updated_duplicates.length > 1 ? 's' : ''} #{affected_updated_duplicates.map(&:id).join(', ')}"
        affected_updated_duplicates.each do |d|
          unless seen.include?(d.id)
            seen.add(d.id)
            csv << [d.id, d.collection_start_year, d.status, d.owning_organisation_name, d.assigned_to_id, d.assigned_to.email, "Leave", "Log updated in UI"]
          end
        end
        affected_non_updated_duplicates.each do |d|
          seen.add(d.id)
          csv << [d.id, d.collection_start_year, d.status, d.owning_organisation_name, d.assigned_to_id, d.assigned_to.email, "Delete", "Log is a duplicate of log(s) which have been updated since being affected", updated_logs_reference]
          unless dry_run
            d.discarded_at = Time.zone.now
            d.status = "deleted"
            d.save!(validate: false)
          end
        end
        next
      end

      latest_created = affected_non_updated_duplicates.max_by(&:created_at)
      seen.add(latest_created.id)
      csv << [latest_created.id, latest_created.collection_start_year, latest_created.status, latest_created.owning_organisation_name, latest_created.assigned_to_id, latest_created.assigned_to.email, "Leave", "Log is the most recently created of a duplicate group"]

      affected_non_updated_duplicates.each do |d|
        next unless d.id != latest_created.id

        seen.add(d.id)
        csv << [d.id, d.collection_start_year, d.status, d.owning_organisation_name, d.assigned_to_id, d.assigned_to.email, "Delete", "Log is a duplicate of more recently created affected log", latest_created.id]
        unless dry_run
          d.discarded_at = Time.zone.now
          d.status = "deleted"
          d.save!(validate: false)
        end
        # rubocop:enable Style/Next
      end
    end
  end

  s3_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
  output_file = "HandleUnpendedLogs_#{dry_run ? 'dry_run' : ''}_#{Time.zone.now}.csv"
  s3_service.write_file(output_file, output)
end
