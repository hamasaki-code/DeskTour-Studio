#!/usr/bin/env ruby
# frozen_string_literal: true

target_files = Dir.glob("app/**/*.{rb,erb}").sort
offenders = target_files.select { |path| File.read(path).match?(/\bdefault:\s*/) }

if offenders.any?
  warn "Found `default:` fallback usage in app files:"
  offenders.each { |path| warn " - #{path}" }
  exit 1
end

puts "No `default:` fallback usage found in app files."
