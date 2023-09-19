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
      create_missing_answers_report(report_suffix, LettingsLog)
      create_missing_answers_report(report_suffix, SalesLog)
    end

    def create_missing_answers_report(report_suffix, log_class)
      class_name = log_class.name.underscore.humanize
      Rails.logger.info("Generating missing imported #{class_name}s answers report")

      unanswered_question_counts, missing_answers_example_sets = process_missing_answers(log_class)

      report_name = "MissingAnswersReport#{log_class.name}_#{report_suffix}.csv"
      @storage_service.write_file(report_name, BYTE_ORDER_MARK + missing_answers_report(unanswered_question_counts))

      examples_report_name = "MissingAnswersExamples#{log_class.name}_#{report_suffix}.csv"
      @storage_service.write_file(examples_report_name, BYTE_ORDER_MARK + missing_answers_examples(missing_answers_example_sets))

      @logger.info("Missing #{class_name}s answers report available in s3 import bucket at #{report_name}")
    end

    def process_missing_answers(log_class)
      unanswered_question_counts = {}
      missing_answers_example_sets = {}

      log_class.where.not(old_id: nil).where(status: "in_progress").each do |log|
        applicable_questions = log.form.subsections.map { |s| s.applicable_questions(log).select { |q| q.enabled?(log) } }.flatten
        unanswered_questions = (applicable_questions.filter { |q| q.unanswered?(log) }.map(&:id) - log.optional_fields).join(", ")

        if unanswered_question_counts[unanswered_questions].present?
          unanswered_question_counts[unanswered_questions] += 1
          missing_answers_example_sets[unanswered_questions] << { id: log.id, old_form_id: log.old_form_id, old_id: log.old_id, owning_organisation_id: log.owning_organisation_id } unless unanswered_question_counts[unanswered_questions] > 10
        else
          unanswered_question_counts[unanswered_questions] = 1
          missing_answers_example_sets[unanswered_questions] = [{ id: log.id, old_form_id: log.old_form_id, old_id: log.old_id, owning_organisation_id: log.owning_organisation_id }]
        end
      end

      [unanswered_question_counts, missing_answers_example_sets]
    end

    def missing_answers_report(unanswered_question_counts)
      CSV.generate do |report|
        headers = ["Missing answers", "Total number of affected logs"]
        report << headers

        unanswered_question_counts.each do |missing_answers, count|
          report << [missing_answers, count]
        end
      end
    end

    def missing_answers_examples(missing_answers_example_sets)
      CSV.generate do |report|
        headers = ["Missing answers", "Organisation ID", "Log ID", "Old Form ID", "Old Log ID"]
        report << headers

        missing_answers_example_sets.each do |missing_answers, examples|
          examples.each do |example|
            report << [missing_answers, example[:owning_organisation_id], example[:id], example[:old_form_id], example[:old_id]]
          end
        end
      end
    end
  end
end
