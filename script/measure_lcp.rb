#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "fileutils"
require "time"
require "selenium-webdriver"

options = {
  url: "http://127.0.0.1:3000/",
  samples: 3,
  label: "after",
  output: "tmp/lcp_measurements.json",
  wait: 3.0
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby script/measure_lcp.rb [options]"

  parser.on("--url URL", "Target URL (default: #{options[:url]})") { |value| options[:url] = value }
  parser.on("--samples N", Integer, "Number of measurement runs (default: #{options[:samples]})") { |value| options[:samples] = value }
  parser.on("--label LABEL", "Measurement label such as before/after (default: #{options[:label]})") { |value| options[:label] = value }
  parser.on("--wait SECONDS", Float, "Wait time after load (default: #{options[:wait]})") { |value| options[:wait] = value }
  parser.on("--output PATH", "JSON output file (default: #{options[:output]})") { |value| options[:output] = value }
end.parse!

def measure_lcp(url, wait_seconds)
  chrome_options = Selenium::WebDriver::Chrome::Options.new
  chrome_options.add_argument("--headless=new")
  chrome_options.add_argument("--disable-gpu")
  chrome_options.add_argument("--window-size=1366,900")

  driver = Selenium::WebDriver.for(:chrome, options: chrome_options)
  driver.navigate.to(url)
  sleep(wait_seconds)

  driver.execute_script(<<~JS)
    const entries = performance.getEntriesByType("largest-contentful-paint");
    if (!entries.length) return null;
    return Math.round(entries[entries.length - 1].startTime);
  JS
ensure
  driver&.quit
end

results = Array.new(options[:samples]) { measure_lcp(options[:url], options[:wait]) }.compact

if results.empty?
  abort("No LCP values were captured. Confirm the page renders an LCP candidate and retry.")
end

sorted = results.sort
median = sorted[sorted.length / 2]
record = {
  timestamp: Time.now.utc.iso8601,
  label: options[:label],
  url: options[:url],
  samples: results,
  median_lcp_ms: median
}

FileUtils.mkdir_p(File.dirname(options[:output]))
history = File.exist?(options[:output]) ? JSON.parse(File.read(options[:output])) : []
history << record
File.write(options[:output], JSON.pretty_generate(history))

puts "LCP median (#{options[:label]}): #{median} ms"
puts "Recorded to: #{options[:output]}"
