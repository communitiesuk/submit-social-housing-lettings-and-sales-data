id = 1
root_url = "http://localhost:3000"
paths = ["/case_logs","/case_logs/#{id}","/case_logs/#{id}/gdpr_acceptance"]

namespace :run_accessibility_test do
  task :run_htmlhint do
    puts "running"
    paths.each do |path|
      system("npx htmlhint #{root_url+path}")
    end
    puts "finished running" 
  end

  task :run_pa11y do
    puts "running"
    paths.each do |path|
      system("npx pa11y --runner axe --runner htmlcs #{root_url+path}")
    end
    puts "finished running" 
  end
end

