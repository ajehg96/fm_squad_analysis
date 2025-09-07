# frozen_string_literal: true

# This file defines a custom Rake task to run all code quality checks.
# You can run it from the terminal with: `bin/rails quality:all`
namespace :quality do
  desc "Run all quality checks: RSpec (with SimpleCov), RuboCop, and Rails Best Practices"
  task all: :environment do
    puts "\n\u{1F9EA} Running RSpec tests and generating coverage report..."
    # The `sh` command will raise an error and stop the task if the command fails.
    sh "bundle exec rspec"
    puts "\u{2728} RSpec tests passed successfully!"

    puts "\n\u{1F46E} Running RuboCop for style guide enforcement..."
    sh "bundle exec rubocop"
    puts "\u{2728} RuboCop found no offences!"

    puts "\n\u{1F4DA} Running Rails Best Practices for code analysis..."
    # We analyse the current directory, indicated by the '.'
    sh "bundle exec rails_best_practices ."
    puts "\u{2728} Rails Best Practices check complete!"

    puts "\n\u{1F3C6} All quality checks passed successfully!"
  end
end
