require "test_helper"

class NoDefaultFallbacksTest < ActiveSupport::TestCase
  CRITICAL_FILES = %w[
    app/views/layouts/application.html.erb
    app/views/posts/index.html.erb
    app/views/posts/show.html.erb
    app/views/posts/_form.html.erb
    app/views/users/show.html.erb
    app/views/shared/_ad_slot.html.erb
    app/views/shared/_feedback_panel.html.erb
    app/controllers/reports_controller.rb
    app/helpers/application_helper.rb
  ].freeze

  test "critical ui files do not use i18n default fallbacks" do
    offenders = CRITICAL_FILES.filter_map do |path|
      content = File.read(Rails.root.join(path))
      path if content.match?(/\bdefault:\s*/)
    end

    assert offenders.empty?, "Remove `default:` from critical files: #{offenders.join(', ')}"
  end
end
