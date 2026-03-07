#!/usr/bin/env ruby
# frozen_string_literal: true

critical_files = %w[
  app/views/layouts/application.html.erb
  app/views/posts/index.html.erb
  app/views/posts/show.html.erb
  app/views/posts/_form.html.erb
  app/views/users/show.html.erb
  app/views/shared/_ad_slot.html.erb
  app/views/shared/_feedback_panel.html.erb
  app/controllers/reports_controller.rb
  app/helpers/application_helper.rb
]

offenders = critical_files.select do |path|
  File.read(path).match?(/\bdefault:\s*/)
end

if offenders.any?
  warn "Found `default:` fallback usage in critical files:"
  offenders.each { |path| warn " - #{path}" }
  exit 1
end

puts "No `default:` fallback usage found in critical files."
