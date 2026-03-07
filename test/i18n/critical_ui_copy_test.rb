require "test_helper"

class CriticalUiCopyTest < ActiveSupport::TestCase
  CRITICAL_KEYS = %w[
    navigation.users_index
    navigation.onboarding
    posts.index.quick_search
    posts.index.filters_now
    posts.index.zero_reason_general
    posts.index.zero_reason_keyword
    posts.index.zero_reason_filters
    posts.index.zero_reason_strict
    posts.index.favorite_saved_notice
    posts.show.mobile_share_section
    posts.show.mobile_report_section
    posts.show.report.intent_confirm
    posts.show.report.intent_opened_notice
    posts.show.ugc_notice
    reports.flash.thanks_with_receipt
    reports.flash.thanks_hidden_with_receipt
    reports.eta
    users.index.heading
    users.show.recent_activity
    users.show.top_categories
    ui.search_hint
    ui.draft_expired
    ui.draft_cleared
    ads.sponsored_label
  ].freeze

  test "critical keys exist in ja and en locales" do
    %i[ja en].each do |locale|
      CRITICAL_KEYS.each do |key|
        assert I18n.exists?(key, locale), "Missing #{key} for locale #{locale}"
      end
    end
  end
end
