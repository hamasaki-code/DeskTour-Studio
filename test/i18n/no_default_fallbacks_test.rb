require "test_helper"

class NoDefaultFallbacksTest < ActiveSupport::TestCase
  TARGET_FILES = Dir.glob(Rails.root.join("app/**/*.{rb,erb}")).map { |path| Pathname.new(path).relative_path_from(Rails.root).to_s }.sort.freeze

  test "app files do not use i18n default fallbacks" do
    offenders = TARGET_FILES.filter_map do |path|
      content = File.read(Rails.root.join(path))
      path if content.match?(/\bdefault:\s*/)
    end

    assert offenders.empty?, "Remove `default:` from app files: #{offenders.join(', ')}"
  end
end
