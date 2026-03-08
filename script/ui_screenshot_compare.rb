#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"

baseline_dir = File.join("test", "visual_baseline")
current_dir = File.join("tmp", "screenshots")

unless Dir.exist?(baseline_dir)
  puts "visual baseline directory not found (#{baseline_dir}); skipping compare."
  exit 0
end

baseline_files = Dir.glob(File.join(baseline_dir, "**", "*.png")).sort
if baseline_files.empty?
  puts "no baseline screenshots found; skipping compare."
  exit 0
end

mismatches = []
missing = []

baseline_files.each do |baseline|
  relative = baseline.delete_prefix("#{baseline_dir}/")
  current = File.join(current_dir, relative)
  unless File.exist?(current)
    missing << relative
    next
  end

  baseline_hash = Digest::SHA256.file(baseline).hexdigest
  current_hash = Digest::SHA256.file(current).hexdigest
  mismatches << relative if baseline_hash != current_hash
end

if missing.any?
  warn "missing screenshot files for comparison:"
  missing.each { |file| warn " - #{file}" }
end

if mismatches.any?
  warn "visual diffs detected against baseline:"
  mismatches.each { |file| warn " - #{file}" }
end

if missing.any? || mismatches.any?
  warn "update baseline screenshots if the changes are intentional."
  exit 1
end

puts "visual screenshot comparison passed."
