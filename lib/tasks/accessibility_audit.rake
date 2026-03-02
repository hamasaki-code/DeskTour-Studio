namespace :accessibility do
  desc "Run recurring accessibility smoke audit"
  task audit: :environment do
    command = "ruby bin/rails test test/accessibility"
    puts "[a11y] running: #{command}"
    success = system(command)
    abort("[a11y] accessibility audit failed") unless success
  end
end
