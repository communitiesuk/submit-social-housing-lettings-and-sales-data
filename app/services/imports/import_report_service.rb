module Imports
  class ImportReportService
    def initialize(storage_service, institutions_csv, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
      @institutions_csv = institutions_csv
    end

    BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

    def create_reports(report_suffix)
      generate_missing_data_coordinators_report(report_suffix)
      generate_logs_report(report_suffix)
      generate_unassigned_logs_report(report_suffix)
    end

    def generate_missing_data_coordinators_report(report_suffix)
      report_csv = "Organisation ID,Old Organisation ID,Organisation Name\n"
      organisations = @institutions_csv.map { |row| Organisation.find_by(name: row[0]) }.compact
      organisations.each do |organisation|
        if organisation.users.none? { |user| user.data_coordinator? && user.active? }
          report_csv += "#{organisation.id},#{organisation.old_visible_id},#{organisation.name}\n"
        end
      end

      report_name = "OrganisationsWithoutDataCoordinators_#{report_suffix}"
      @storage_service.write_file(report_name, BYTE_ORDER_MARK + report_csv)

      @logger.info("Missing data coordinators report available in s3 import bucket at #{report_name}")
    end

    def generate_logs_report(report_suffix)
      Rails.logger.info("Generating migrated logs report")

      rep = CSV.generate do |report|
        headers = ["Institution name", "Id", "Old Completed lettings logs", "Old In progress lettings logs", "Old Completed sales logs", "Old In progress sales logs", "New Completed lettings logs", "New In Progress lettings logs", "New Completed sales logs", "New In Progress sales logs"]
        report << headers

        @institutions_csv.each do |row|
          name = row[0]
          organisation = Organisation.find_by(name:)
          next unless organisation

          completed_sales_logs = organisation.owned_sales_logs.where(status: "completed").count
          in_progress_sales_logs = organisation.owned_sales_logs.where(status: "in_progress").count
          completed_lettings_logs = organisation.owned_lettings_logs.where(status: "completed").count
          in_progress_lettings_logs = organisation.owned_lettings_logs.where(status: "in_progress").count
          report << row.push(completed_lettings_logs, in_progress_lettings_logs, completed_sales_logs, in_progress_sales_logs)
        end
      end

      report_name = "MigratedLogsReport_#{report_suffix}"
      @storage_service.write_file(report_name, BYTE_ORDER_MARK + rep)

      @logger.info("Logs report available in s3 import bucket at #{report_name}")
    end

    def generate_unassigned_logs_report(report_suffix)
      Rails.logger.info("Generating unassigned logs report")

      rep = CSV.generate do |report|
        headers = ["Owning Organisation ID", "Old Owning Organisation ID", "Managing Organisation ID", "Old Managing Organisation ID", "Log ID", "Old Log ID", "Tenancy code", "Purchaser code"]
        report << headers

        @institutions_csv.each do |row|
          name = row[0]
          organisation = Organisation.find_by(name:)
          next unless organisation

          unassigned_user = organisation.users.find_by(name: "Unassigned")
          next unless unassigned_user

          organisation.owned_lettings_logs.where(created_by: unassigned_user).each do |lettings_log|
            report << [organisation.id, organisation.old_org_id, lettings_log.managing_organisation.id, lettings_log.managing_organisation.old_org_id, lettings_log.id, lettings_log.old_id, lettings_log.tenancycode, nil]
          end
          organisation.owned_sales_logs.where(created_by: unassigned_user).each do |sales_log|
            report << [organisation.id, organisation.old_org_id, nil, nil, sales_log.id, sales_log.old_id, nil, sales_log.purchid]
          end
        end
      end

      report_name = "UnassignedLogsReport_#{report_suffix}"
      @storage_service.write_file(report_name, BYTE_ORDER_MARK + rep)

      @logger.info("Unassigned logs report available in s3 import bucket at #{report_name}")
    end

    def generate_missing_answers_report(report_suffix)
      Rails.logger.info("Generating missing imported lettings logs answers report")

      rep = CSV.generate do |report|
        headers = ["Missing answers", "Total number of affected logs"]
        report << headers

        unanswered_question_counts = {}

        LettingsLog.where.not(old_id: nil).where(status: "in_progress").each do |lettings_log|
          applicable_questions = lettings_log.form.subsections.map { |s| s.applicable_questions(lettings_log).select { |q| q.enabled?(lettings_log) } }.flatten
          unanswered_questions = applicable_questions.filter { |q| q.unanswered?(lettings_log) }.map(&:id) - lettings_log.optional_fields

          if unanswered_question_counts[unanswered_questions.join(", ")].present?
            unanswered_question_counts[unanswered_questions.join(", ")] += 1
          else
            unanswered_question_counts[unanswered_questions.join(", ")] = 1
          end
        end

        unanswered_question_counts.each do |missing_answers, count|
          report << [missing_answers, count]
        end
      end

      report_name = "MissingAnswersReport_#{report_suffix}.csv"
      @storage_service.write_file(report_name, BYTE_ORDER_MARK + rep)

      @logger.info("Missing answers report available in s3 import bucket at #{report_name}")
    end
  end
end
