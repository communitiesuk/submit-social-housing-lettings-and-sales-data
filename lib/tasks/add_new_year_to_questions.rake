require "pathname"

desc "Add a new year to all lettings question number hashes and saves the new code.
Usage: bundle exec rake add_new_year_to_questions[new_year,log_type].
Example: bundle exec rake add_new_year_to_questions[2027,lettings].
This rake should only be run as part of local development at the start of new collection year creation.
Make sure your working tree is clean before running this, it will update each question file in place.
Note that this will only update questions with a QUESTION_NUMBER_FROM_YEAR hash set.
Some questions (such as any of the per person questions) which define custom question logic will need manual review.
Params:
- new_year: the year to add, e.g. 2025
- log_type: the type of log to update. can be lettings or sales"
task :add_new_year_to_questions, %i[new_year log_type] => :environment do |_task, args|
  new_year = args[:new_year].to_i
  previous_year = new_year - 1

  root = Pathname.new("app/models/form/#{args[:log_type]}/questions")
  files = root.glob("*.rb")

  hash_re = /QUESTION_NUMBER_FROM_YEAR\s*=\s*\{([^}]*)}\.freeze/m

  changed = []

  files.each do |path|
    text = path.read
    next unless text.include?("QUESTION_NUMBER_FROM_YEAR")

    match = hash_re.match(text)
    next unless match

    body = match[1]
    pairs = body.scan(/(\d+)\s*=>\s*(\d+)/)
    next if pairs.empty?

    year_to_num = pairs.to_h { |y, n| [y.to_i, n.to_i] }
    next if year_to_num.key?(new_year)
    next unless year_to_num.key?(previous_year)

    year_to_num[new_year] = year_to_num[previous_year]

    items = year_to_num.keys.sort.map { |y| "#{y} => #{year_to_num[y]}" }.join(", ")
    replacement = "QUESTION_NUMBER_FROM_YEAR = { #{items} }.freeze"

    new_text = text.sub(hash_re, replacement)

    next if new_text == text

    path.write(new_text)
    changed << path
  end

  puts "changed #{changed.length}"
  changed.each { |p| puts p }
end

