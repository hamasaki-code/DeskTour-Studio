namespace :adsense do
  desc "Run a practical preflight check for AdSense submission readiness"
  task preflight: :environment do
    checks = []

    published_posts_count = Post.visible.count
    checks << [ published_posts_count >= 10, "Published posts: #{published_posts_count} (need about 10+)" ]
    checks << [ User.joins(:posts).merge(Post.visible).distinct.count.positive?, "At least one public profile with visible posts" ]
    checks << [ File.exist?(Rails.root.join("public/robots.txt")), "robots.txt exists" ]
    checks << [ File.exist?(Rails.root.join("app/views/sitemaps/show.xml.builder")), "sitemap.xml view exists" ]
    checks << [ ENV["APP_HOST"].to_s.strip.present?, "APP_HOST is configured" ]
    checks << [ ENV["SEARCH_CONSOLE_VERIFICATION_TOKEN"].to_s.strip.present?, "Search Console verification token is configured" ]
    checks << [ ENV["SITE_OPERATOR_NAME"].to_s.strip.present?, "Operator name is configured" ]
    checks << [ ENV["SUPPORT_INBOX_EMAIL"].to_s.strip.present?, "Support inbox email is configured" ]
    checks << [ ENV["ADSENSE_PUBLISHER_ID"].to_s.strip.present?, "AdSense publisher ID is configured for ads.txt" ]
    checks << [ ENV["ENABLE_EDITORIAL_DEMO_CONTENT"].to_s != "true", "Editorial demo content is disabled for production review" ]

    puts "AdSense preflight"
    puts "-" * 60

    checks.each do |passed, message|
      marker = passed ? "[OK]" : "[TODO]"
      puts "#{marker} #{message}"
    end

    puts "-" * 60
    pending = checks.count { |passed, _| !passed }
    puts pending.zero? ? "All automated checks passed." : "#{pending} item(s) still need attention."
  end
end
