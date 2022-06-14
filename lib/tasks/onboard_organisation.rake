load './lib/tasks/data_import.rake'

namespace :core do
  desc "Import data XMLs from Softwire system"
  task :onboard_organisation, %i[S3_prefix] => :environment do |_task, args|
    S3_prefix = args[:S3_prefix]
    Rake::Task["core:data_import"].invoke("organisation", "#{S3_prefix}/institution/")
    Rake::Task["core:data_import"].invoke("user", "#{S3_prefix}/user/")
    Rake::Task["core:data_import"].invoke("data-protection-confirmation", "#{S3_prefix}/dataprotect/")
    Rake::Task["core:data_import"].invoke("organisation-rent-periods", "#{S3_prefix}/rent-period/")
    Rake::Task["core:data_import"].invoke("logs", "#{S3_prefix}/logs/")
  end
end