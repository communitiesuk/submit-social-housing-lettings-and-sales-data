module Csv
  class MissingIllnessCsvService
    def initialize(organisation)
      @organisation = organisation
    end

    def create_illness_csv
      logs = @organisation.managed_lettings_logs
      .imported
      .after_date(Time.zone.local(2022, 4, 1))
      .with_illness_without_type

      CSV.generate(headers: false) do |csv|
        csv << ["Question",	"Log ID",	"Tenancy start date",	"Tenant code",	"Property reference",	"Log owner",	"Owning organisation",	"Managing organisation",	"Does anybody in the household have a physical or mental health condition (or other illness) expected to last 12 months or more?",	"Does this person's condition affect their vision?",	"Does this person's condition affect their hearing?",	"Does this person's condition affect their mobility?",	"Does this person's condition affect their dexterity?", "Does this person's condition affect their learning or understanding or concentrating?",	"Does this person's condition affect their memory?",	"Does this person's condition affect their mental health?", "Does this person's condition affect their stamina or breathing or fatigue?",	"Does this person's condition affect them socially or behaviourally?",	"Does this person's condition affect them in another way?"]
        csv << ["Additional info", nil, nil, nil, nil, nil, nil, nil, nil, "For example, blindness or partial sight", "For example, deafness or partial hearing", nil, "For example, lifting and carrying objects, or using a keyboard", nil, nil, "For example, depression or anxiety", nil, "Anything associated with autism spectrum disorder (ASD), including Asperger's or attention deficit hyperactivity disorder (ADHD)", nil, nil]
        csv << ["How to answer",	"Do not change the answers for this field",	"Do not change the answers for this field",	"Do not change the answers for this field",	"Do not change the answers for this field",	"Do not change the answers for this field",	"Do not change the answers for this field",	"Do not change the answers for this field",	"1 = Yes; 2 = No; 3 = Prefers not to say",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No",	"1 = Yes; blank = No"]

        logs.each do |log|
          csv << log_to_csv_row(log)
        end
      end
    end

  private

    def log_to_csv_row(log)
      [nil,
       log.id,
       log.startdate&.to_date,
       log.tenancycode,
       log.propcode,
       log.created_by&.email,
       log.owning_organisation&.name,
       log.managing_organisation&.name,
       1,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil]
    end
  end
end
