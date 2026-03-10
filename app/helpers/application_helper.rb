module ApplicationHelper
  POST_IMAGE_VARIANTS = {
    thumbnail: {
      resize_to_fill: [640, 360],
      format: :webp
    },
    main: {
      resize_to_limit: [1600, 1600],
      format: :webp
    },
    og: {
      resize_to_fill: [1200, 630],
      format: :jpg
    }
  }.freeze

  POST_IMAGE_DIMENSIONS = {
    thumbnail: [640, 360],
    main: [1200, 750],
    og: [1200, 630]
  }.freeze

  FALLBACK_POST_IMAGE = "default-desk.svg"

  FLASH_VISUALS = {
    "notice" => {
      level: :success,
      icon: :check_circle,
      label_key: "status_levels.success"
    },
    "warning" => {
      level: :warning,
      icon: :exclamation_triangle,
      label_key: "status_levels.warning"
    },
    "alert" => {
      level: :error,
      icon: :x_circle,
      label_key: "status_levels.error"
    }
  }.freeze

  ITEM_BRAND_PATTERNS = {
    "Apple" => [/\bapple\b/i, /\bmacbook\b/i, /\bipad\b/i, /\biphone\b/i],
    "Logitech" => [/\blogitech\b/i, /\blogi\b/i],
    "Razer" => [/\brazer\b/i],
    "SteelSeries" => [/\bsteelseries\b/i],
    "Dell" => [/\bdell\b/i],
    "LG" => [/\blg\b/i],
    "Samsung" => [/\bsamsung\b/i],
    "BenQ" => [/\bbenq\b/i],
    "Sony" => [/\bsony\b/i],
    "Bose" => [/\bbose\b/i],
    "Audio-Technica" => [/\baudio[- ]?technica\b/i],
    "Sennheiser" => [/\bsennheiser\b/i],
    "Anker" => [/\banker\b/i, /\bpowerconf\b/i],
    "IKEA" => [/\bikea\b/i],
    "Herman Miller" => [/\bherman[\s\-]?miller\b/i],
    "NOBLECHAIRS" => [/\bnoblechairs\b/i],
    "Keychron" => [/\bkeychron\b/i],
    "HHKB" => [/\bhhkb\b/i]
  }.freeze

  ITEM_HOST_BRAND_HINTS = {
    /apple\.com\z/i => "Apple",
    /logitech\./i => "Logitech",
    /razer\./i => "Razer",
    /steelseries\./i => "SteelSeries",
    /dell\.com\z/i => "Dell",
    /lg\.com\z/i => "LG",
    /samsung\.com\z/i => "Samsung",
    /benq\./i => "BenQ",
    /sony\./i => "Sony",
    /bose\./i => "Bose",
    /audio-technica\./i => "Audio-Technica",
    /sennheiser\./i => "Sennheiser",
    /anker\./i => "Anker",
    /ikea\./i => "IKEA",
    /hermanmiller\./i => "Herman Miller",
    /keychron\./i => "Keychron"
  }.freeze

  ITEM_CATEGORY_KEYWORDS = {
    keyboard: ["keyboard", "keycap", "switch", "hhkb", "keychron"],
    monitor: ["monitor", "display", "ultrawide", "screen", "4k"],
    laptop: ["laptop", "macbook", "thinkpad", "notebook", "surface"],
    desk: ["desk", "standing desk", "table", "workstation"],
    chair: ["chair", "stool", "ergonomic chair"],
    audio: ["headphone", "earphone", "speaker", "mic", "microphone", "dac"],
    lighting: ["lamp", "light", "led", "light bar", "lighting"],
    pointer: ["mouse", "trackpad", "trackball"],
    camera: ["webcam", "camera", "cam"],
    dock: ["dock", "hub", "kvm", "thunderbolt"],
    storage: ["ssd", "hdd", "nas", "drive"]
  }.freeze

  ITEM_GENERIC_BRAND_TOKENS = %w[desk setup monitor keyboard mouse chair table stand with for and the a an rgb].freeze
  GENERIC_POST_TAGS = %w[desk setup workspace workstation minimal home office room pc].freeze

  def ga4_measurement_id
    ENV["GA4_MEASUREMENT_ID"].to_s.strip.presence
  end

  def ga4_enabled?
    Rails.env.production? && ga4_measurement_id.present?
  end

  def search_console_verification_token
    return unless Rails.env.production?

    ENV["SEARCH_CONSOLE_VERIFICATION_TOKEN"].to_s.strip.presence
  end

  def analytics_events
    Array(flash[:analytics_events]).filter_map do |event|
      next unless event.is_a?(Hash)

      name = event["name"] || event[:name]
      next if name.blank?

      params = event["params"] || event[:params] || {}
      next unless params.is_a?(Hash)

      { name: name.to_s, params: params }
    end
  end

  def page_title(custom_title = nil)
    base = "DeskTour Studio"
    return base if custom_title.blank?

    "#{custom_title} | #{base}"
  end

  def meta_description(custom_description = nil)
    custom_description.presence || t("meta.default_description")
  end

  def share_card_title(raw_title)
    truncate(raw_title.to_s.presence || "DeskTour Studio", length: 65)
  end

  def share_card_description(raw_description)
    truncate(raw_description.to_s.presence || t("meta.default_description"), length: 150)
  end

  def canonical_url
    request.base_url + request.path
  end

  def og_image_url(post = nil)
    if post&.desk_image&.attached?
      url_for(post.desk_image.variant(variant_options(:og)))
    else
      "#{request.base_url}#{image_path(FALLBACK_POST_IMAGE)}"
    end
  end

  def optimized_post_image_source(post, variant: :thumbnail)
    if post&.desk_image&.attached?
      post.desk_image.variant(variant_options(variant))
    else
      FALLBACK_POST_IMAGE
    end
  end

  def optimized_post_image_tag(post, variant: :thumbnail, **options)
    class_names = [options[:class]]
    class_names << "ds-thumbnail-crop" if variant.to_sym == :thumbnail
    options[:class] = class_names.compact.join(" ")

    image_tag(
      optimized_post_image_source(post, variant: variant),
      **default_image_tag_options(post, variant).merge(options)
    )
  end

  def post_share_text(post)
    t("share.post_text", title: post.title)
  end

  def post_share_url(post)
    post_url(post)
  end

  def x_share_url(post)
    "https://x.com/intent/tweet?text=#{ERB::Util.url_encode(post_share_text(post))}&url=#{ERB::Util.url_encode(post_share_url(post))}"
  end

  def threads_share_url(post)
    "https://www.threads.net/intent/post?text=#{ERB::Util.url_encode("#{post_share_text(post)} #{post_share_url(post)}")}"
  end

  def localized_number(value)
    number_with_delimiter(value, locale: I18n.locale)
  end

  def context_breadcrumbs
    base = [{ label: "DeskTour Studio", href: root_path }]

    if controller_path.start_with?("admin/")
      admin_root = { label: t("navigation.admin"), href: admin_posts_path }
      base << admin_root

      case controller_path
      when "admin/posts"
        base << { label: t("navigation.admin_posts"), href: admin_posts_path }
      when "admin/reports"
        base << { label: t("navigation.admin_reports"), href: admin_reports_path }
      end

      return base
    end

    return base if controller_name == "posts" && action_name == "index"

    case controller_name
    when "posts"
      base << { label: t("posts.index.title"), href: root_path }

      if action_name == "show" && defined?(@post) && @post.present?
        base << { label: truncate(@post.title, length: 40), href: post_path(@post) }
      elsif action_name == "notifications" && defined?(@post) && @post.present?
        base << { label: truncate(@post.title, length: 40), href: post_path(@post) }
        base << { label: t("posts.notifications.heading"), href: notifications_post_path(@post) }
      elsif action_name.in?(%w[new create])
        base << { label: t("posts.new.heading"), href: new_post_path }
      elsif action_name.in?(%w[edit update]) && defined?(@post) && @post.present?
        base << { label: truncate(@post.title, length: 40), href: post_path(@post) }
        base << { label: t("posts.edit.heading"), href: edit_post_path(@post) }
      end
    when "users"
      if action_name == "index"
        base << { label: t("users.index.heading"), href: users_path }
      elsif action_name.in?(%w[new create])
        base << { label: t("users.new.heading"), href: new_user_path }
      elsif defined?(@user) && @user.present?
        base << { label: t("users.index.heading"), href: users_path }
        base << { label: @user.name, href: user_path(@user) }
        base << { label: t("users.edit.heading"), href: edit_user_path(@user) } if action_name.in?(%w[edit update])
      end
    when "pages"
      page_map = {
        "privacy" => { label: t("footer.privacy_policy"), href: privacy_policy_path },
        "terms" => { label: t("footer.terms"), href: terms_path },
        "cookie" => { label: t("footer.cookie_policy"), href: cookie_policy_path },
        "onboarding" => { label: t("navigation.onboarding"), href: onboarding_path }
      }
      candidate = page_map[action_name]
      base << candidate if candidate.present?
    end

    base
  end

  def reading_sections(text)
    raw = text.to_s
    return [] if raw.blank?

    sections = []
    current = { title: t("posts.show.section_overview"), lines: [] }

    raw.each_line do |line|
      heading_match = line.match(/\A##\s+(.+)\z/)
      if heading_match
        sections << current if current[:lines].any?
        current = { title: heading_match[1].strip, lines: [] }
      else
        current[:lines] << line
      end
    end

    sections << current if current[:lines].any?

    sections.each_with_index.map do |section, idx|
      section_fallback = "#{t('posts.show.section_label')} #{idx + 1}"
      {
        id: "section-#{idx + 1}",
        title: section[:title].presence || section_fallback,
        body: section[:lines].join.strip
      }
    end.reject { |section| section[:body].blank? }
  end

  def sort_option_label(value)
    labels = {
      "newest" => t("posts.index.sort_newest"),
      "popular" => t("posts.index.sort_popular"),
      "recently_updated" => t("posts.index.sort_recently_updated")
    }
    labels.fetch(value.to_s, labels.fetch("newest"))
  end

  def sort_option_hint(value)
    hints = {
      "newest" => t("posts.index.sort_hint_newest"),
      "popular" => t("posts.index.sort_hint_popular"),
      "recently_updated" => t("posts.index.sort_hint_recently_updated")
    }
    hints.fetch(value.to_s, hints.fetch("newest"))
  end

  def formatted_date(value)
    return "" if value.blank?

    l(value.to_date, format: :default)
  end

  def formatted_datetime(value)
    return "" if value.blank?

    l(value, format: :short)
  end

  def timestamp_tag(value, style: :datetime, include_relative: false)
    return "" if value.blank?

    label = style == :date ? formatted_date(value) : formatted_datetime(value)
    aria_label =
      if include_relative
        distance = distance_of_time_in_words(value, Time.current)
        relative =
          if I18n.exists?("time.relative_ago")
            t("time.relative_ago", distance: distance)
          elsif I18n.locale.to_s == "ja"
            "#{distance}前"
          else
            "#{distance} ago"
          end

        "#{label} (#{relative})"
      else
        label
      end

    content_tag(:time, label, datetime: value.to_time.iso8601, title: aria_label, "aria-label": aria_label)
  end

  def flash_visual(type)
    FLASH_VISUALS.fetch(type.to_s, FLASH_VISUALS.fetch("notice"))
  end

  def prioritized_post_tags(post, query:, category:, selected_tag:)
    tags = post.tags.map(&:to_s).map(&:strip).reject(&:blank?)
    return [] if tags.empty?

    selected = selected_tag.to_s.downcase
    category_down = category.to_s.downcase
    query_tokens = query.to_s.downcase.split(/[\s,\/_-]+/).map(&:strip).reject(&:blank?).first(6)

    tags.sort_by do |tag|
      normalized = tag.downcase
      score = 0
      score += 8 if selected.present? && normalized == selected
      score += 4 if category_down.present? && (normalized.include?(category_down) || category_down.include?(normalized))
      score += 3 if query_tokens.any? { |token| normalized.include?(token) || token.include?(normalized) }
      score -= 1 if GENERIC_POST_TAGS.include?(normalized)
      [-score, tag]
    end
  end

  def related_item_facts(item)
    name = item.name.to_s.strip
    url = item.affiliate_url.to_s.strip
    downcased = name.downcase
    host, url_text, query_params = extract_url_info(url)

    facts = []

    brand = extract_brand(name, host: host)
    if brand.present?
      facts << { key: :brand, label: t("posts.show.item_brand"), value: brand }
    end

    category = guess_item_category("#{downcased} #{url_text}".strip)
    if category.present?
      category_key = "posts.show.item_categories.#{category}"
      category_label = I18n.exists?(category_key) ? t(category_key) : category.to_s.humanize
      facts << { key: :category, label: t("posts.show.item_category"), value: category_label }
    end

    price = extract_price(name: name, url_text: url_text, query_params: query_params)
    if price.present?
      facts << { key: :price, label: t("posts.show.item_price"), value: price }
    end

    if host.present?
      facts << { key: :source, label: t("posts.show.item_source"), value: host }
    end

    priority = { brand: 0, category: 1, price: 2, source: 3 }
    facts
      .uniq { |fact| [fact[:key], fact[:value]] }
      .sort_by { |fact| priority.fetch(fact[:key], 99) }
      .first(3)
  end

  def related_item_label(key)
    label_key = "posts.show.item_#{key}"
    I18n.exists?(label_key) ? t(label_key) : key.to_s.humanize
  end

  def status_level_label(level)
    label_key = "status_levels.#{level}"
    I18n.exists?(label_key) ? t(label_key) : level.to_s.humanize
  end

  def status_badge(level:, label:, icon:)
    tones = {
      success: "ds-tone-success",
      warning: "ds-tone-warning",
      error: "ds-tone-danger",
      info: "ds-tone-info"
    }
    tone = tones.fetch(level.to_sym, tones.fetch(:info))

    content_tag(:span, class: "inline-flex items-center gap-1.5 rounded-full border px-2 py-0.5 text-xs font-medium #{tone}") do
      safe_join([ui_icon(icon, class_name: "h-3.5 w-3.5"), content_tag(:span, label)])
    end
  end

  def report_status_badge(status)
    variants = {
      "queued" => { level: :warning, icon: :clock, label_key: "report_status.queued" },
      "dismissed" => { level: :info, icon: :minus_circle, label_key: "report_status.dismissed" },
      "restored" => { level: :success, icon: :check_circle, label_key: "report_status.restored" }
    }
    visual = variants.fetch(status.to_s, { level: :info, icon: :information_circle, label_key: "report_status.unknown" })

    status_badge(level: visual[:level], icon: visual[:icon], label: t(visual[:label_key]))
  end

  def post_status_badge(status)
    variants = {
      "draft" => { level: :warning, icon: :clock, label_key: "post_status.draft" },
      "published" => { level: :success, icon: :check_circle, label_key: "post_status.published" },
      "hidden" => { level: :error, icon: :x_circle, label_key: "post_status.hidden" }
    }
    visual = variants.fetch(status.to_s, { level: :info, icon: :information_circle, label_key: "post_status.unknown" })

    status_badge(level: visual[:level], icon: visual[:icon], label: t(visual[:label_key]))
  end

  def policy_inline_copy(context)
    context_key = "legal.contexts.#{context}"
    summary_key = "#{context_key}.summary"
    details_key = "#{context_key}.details"
    heading_key = "#{context_key}.heading"

    {
      heading: I18n.exists?(heading_key) ? t(heading_key) : t("legal.inline.heading"),
      summary: I18n.exists?(summary_key) ? Array(t(summary_key)) : [],
      details: I18n.exists?(details_key) ? Array(t(details_key)) : []
    }
  end

  def policy_revision_notice
    revision_id = ENV["POLICY_REVISION_ID"].to_s.strip
    return if revision_id.blank?

    highlight_lines = ENV["POLICY_REVISION_HIGHLIGHTS"].to_s.split("|").map(&:strip).reject(&:blank?)
    effective_on_raw = ENV["POLICY_REVISION_EFFECTIVE_ON"].to_s.strip
    effective_on =
      begin
        effective_on_raw.present? ? Date.parse(effective_on_raw) : nil
      rescue ArgumentError
        effective_on_raw.presence
      end

    {
      id: revision_id,
      effective_on: effective_on,
      summary: ENV["POLICY_REVISION_SUMMARY"].to_s.strip.presence || t("legal.revision.default_summary"),
      highlights: highlight_lines,
      link: ENV["POLICY_REVISION_LINK"].to_s.strip.presence || terms_path
    }
  end

  def ui_icon(name, class_name: "h-4 w-4")
    path_attrs = { "stroke-linecap": "round", "stroke-linejoin": "round" }

    paths = case name.to_sym
    when :check
      [
        tag.path(path_attrs.merge(d: "m4.5 12.75 4.5 4.5 10.5-10.5"))
      ]
    when :check_circle
      [
        tag.path(path_attrs.merge(d: "m9 12.75 2.25 2.25 3.75-3.75")),
        tag.path(path_attrs.merge(d: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"))
      ]
    when :exclamation_triangle
      [
        tag.path(path_attrs.merge(d: "M12 9v3.75m0 3.75h.008v.008H12v-.008Z")),
        tag.path(path_attrs.merge(d: "m10.29 3.86-7.31 12.65A2 2 0 0 0 4.69 19.5h14.62a2 2 0 0 0 1.73-2.99L13.73 3.86a2 2 0 0 0-3.46 0Z"))
      ]
    when :x_circle
      [
        tag.path(path_attrs.merge(d: "m14.25 9.75-4.5 4.5m0-4.5 4.5 4.5")),
        tag.path(path_attrs.merge(d: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"))
      ]
    when :information_circle
      [
        tag.path(path_attrs.merge(d: "m11.25 11.25.041-.02a.75.75 0 0 1 1.06.852l-.708 2.836a.75.75 0 0 0 1.06.852l.041-.02")),
        tag.path(path_attrs.merge(d: "M12 8.25h.008v.008H12V8.25Z")),
        tag.path(path_attrs.merge(d: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"))
      ]
    when :clock
      [
        tag.path(path_attrs.merge(d: "M12 6v6l4 2")),
        tag.path(path_attrs.merge(d: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"))
      ]
    when :minus_circle
      [
        tag.path(path_attrs.merge(d: "M9.75 12h4.5")),
        tag.path(path_attrs.merge(d: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"))
      ]
    when :heart
      [
        tag.path(path_attrs.merge(d: "m21 8.25c0-2.485-2.015-4.5-4.5-4.5-1.74 0-3.248.99-4 2.438A4.484 4.484 0 0 0 8.5 3.75C6.015 3.75 4 5.765 4 8.25c0 4.025 4.5 7.5 8 10.5 3.5-3 8-6.475 8-10.5Z"))
      ]
    when :globe_alt
      [
        tag.path(path_attrs.merge(d: "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z")),
        tag.path(path_attrs.merge(d: "M3.6 9h16.8M3.6 15h16.8")),
        tag.path(path_attrs.merge(d: "M12 3c2.4 2.4 3.6 5.4 3.6 9s-1.2 6.6-3.6 9m0-18c-2.4 2.4-3.6 5.4-3.6 9s1.2 6.6 3.6 9"))
      ]
    when :share
      [
        tag.path(path_attrs.merge(d: "M8.25 12a3.75 3.75 0 1 0 0-7.5 3.75 3.75 0 0 0 0 7.5Zm7.5 7.5a3.75 3.75 0 1 0 0-7.5 3.75 3.75 0 0 0 0 7.5Zm0-15a3.75 3.75 0 1 0 0 7.5 3.75 3.75 0 0 0 0-7.5Z")),
        tag.path(path_attrs.merge(d: "m11.4 10.3 3 1.4m-3 2 3.1-1.5"))
      ]
    when :ellipsis_horizontal
      [
        tag.path(path_attrs.merge(d: "M6.75 12a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm6 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm6 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"))
      ]
    when :flag
      [
        tag.path(path_attrs.merge(d: "M5.25 21V4.5m0 0h10.5l-1.5 3 1.5 3H5.25Z"))
      ]
    when :chat
      [
        tag.path(path_attrs.merge(d: "M7.5 8.25h9m-9 3h6m-9 9 2.7-2.16a2.25 2.25 0 0 1 1.4-.5h7.65A2.25 2.25 0 0 0 18.75 15V6A2.25 2.25 0 0 0 16.5 3.75h-9A2.25 2.25 0 0 0 5.25 6v12.75Z"))
      ]
    when :arrow_uturn_left
      [
        tag.path(path_attrs.merge(d: "m9 9-4.5 4.5L9 18")),
        tag.path(path_attrs.merge(d: "M4.5 13.5H15A4.5 4.5 0 0 1 19.5 18"))
      ]
    when :pencil_square
      [
        tag.path(path_attrs.merge(d: "M16.86 3.49a2.12 2.12 0 1 1 3 3L8.25 18.11 4.5 19.5l1.39-3.75L16.86 3.49Z")),
        tag.path(path_attrs.merge(d: "M12 6.75H5.25A2.25 2.25 0 0 0 3 9v9.75A2.25 2.25 0 0 0 5.25 21h9.75A2.25 2.25 0 0 0 17.25 18v-6.75"))
      ]
    when :bell
      [
        tag.path(path_attrs.merge(d: "M14.25 18.75a2.25 2.25 0 0 1-4.5 0m8.25-2.25H6a1.5 1.5 0 0 1-1.35-2.14l.85-1.7a6.75 6.75 0 1 0 13 0l.85 1.7A1.5 1.5 0 0 1 18 16.5Z"))
      ]
    when :trash
      [
        tag.path(path_attrs.merge(d: "M6 7.5h12m-9 0v10.5m3-10.5v10.5M9 4.5h6m-8.25 3h10.5l-.75 11.25a2.25 2.25 0 0 1-2.25 2.1h-4.5a2.25 2.25 0 0 1-2.25-2.1L6.75 7.5Z"))
      ]
    when :bars_3
      [
        tag.path(path_attrs.merge(d: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"))
      ]
    when :chevron_down
      [
        tag.path(path_attrs.merge(d: "m19.5 8.25-7.5 7.5-7.5-7.5"))
      ]
    when :bookmark
      [
        tag.path(path_attrs.merge(d: "M17.25 21 12 17.25 6.75 21V5.25A2.25 2.25 0 0 1 9 3h6a2.25 2.25 0 0 1 2.25 2.25V21Z"))
      ]
    when :bookmark_solid
      [
        tag.path(d: "M6.75 3A2.25 2.25 0 0 0 4.5 5.25V21l7.5-4.5 7.5 4.5V5.25A2.25 2.25 0 0 0 17.25 3h-10.5Z", fill: "currentColor", stroke: "none")
      ]
    else
      [
        tag.path(path_attrs.merge(d: "M12 6v6m0 4h.01M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"))
      ]
    end

    content_tag(
      :svg,
      safe_join(paths),
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewBox: "0 0 24 24",
      stroke: "currentColor",
      "stroke-width": "1.8",
      class: class_name,
      "aria-hidden": "true"
    )
  end

  private

  def extract_url_info(url)
    return ["", "", {}] if url.blank?

    normalized_url = url.to_s.strip
    normalized_url = "https://#{normalized_url}" if normalized_url.present? && normalized_url !~ /\A[a-z][a-z0-9+\-.]*:\/\//i

    uri = URI.parse(normalized_url)
    host = uri.host.to_s.sub(/\Awww\./, "")
    text = URI.decode_www_form_component([uri.path, uri.query].compact.join(" "))
    query_params = URI.decode_www_form(uri.query.to_s).to_h.transform_keys(&:downcase)
    [host, text, query_params]
  rescue URI::InvalidURIError, ArgumentError
    ["", "", {}]
  end

  def extract_brand(name, host:)
    ITEM_BRAND_PATTERNS.each do |label, patterns|
      return label if patterns.any? { |pattern| name.match?(pattern) }
    end

    if host.present?
      ITEM_HOST_BRAND_HINTS.each do |pattern, label|
        return label if host.match?(pattern)
      end
    end

    first_token = name.split(/\s+/).first.to_s.gsub(/[^0-9A-Za-z\-\+]/, "")
    return if first_token.blank? || first_token.length < 3
    return if ITEM_GENERIC_BRAND_TOKENS.include?(first_token.downcase)

    first_token
  end

  def guess_item_category(name)
    return if name.blank?

    ITEM_CATEGORY_KEYWORDS.each do |category, keywords|
      return category if keywords.any? { |word| name.include?(word) }
    end

    nil
  end

  def extract_price(name:, url_text:, query_params:)
    text = [name, url_text].compact.join(" ")
    return if text.blank?

    currency_price_patterns = [
      /(?:[$]|\u{00A5}|\u{20AC}|\u{00A3})\s?\d[\d,]*(?:\.\d{1,2})?(?:\s?-\s?(?:[$]|\u{00A5}|\u{20AC}|\u{00A3})?\s?\d[\d,]*(?:\.\d{1,2})?)?/,
      /\b(?:USD|JPY|EUR|GBP)\s?\d[\d,]*(?:\.\d{1,2})?\b/i,
      /\b\d[\d,]*(?:\.\d{1,2})?\s?(?:USD|JPY|EUR|GBP)\b/i
    ]

    detected = currency_price_patterns.lazy.map { |pattern| text[pattern] }.find(&:present?)
    return detected.strip if detected.present?

    price_value = query_params.values_at("price", "amount", "cost", "sale_price").find { |value| value.to_s.match?(/\A\d[\d,]*(?:\.\d{1,2})?\z/) }
    return if price_value.blank?

    currency = query_params["currency"].to_s.upcase
    currency.present? ? "#{currency} #{price_value}" : price_value
  end

  def variant_options(key)
    POST_IMAGE_VARIANTS.fetch(key)
  rescue KeyError
    raise ArgumentError, "Unknown image variant: #{key.inspect}"
  end

  def default_image_tag_options(post, variant)
    width, height = POST_IMAGE_DIMENSIONS.fetch(variant, POST_IMAGE_DIMENSIONS[:main])
    fallback_url = asset_path(FALLBACK_POST_IMAGE)

    base = {
      alt: post&.title.presence || t("images.desk_alt"),
      decoding: "async",
      width: width,
      height: height,
      data: { fallback_src: fallback_url }
    }

    if variant == :thumbnail
      base.merge(loading: "lazy", sizes: "(min-width: 1024px) 33vw, (min-width: 640px) 50vw, 100vw")
    else
      base.merge(loading: "eager", fetchpriority: "high", sizes: "100vw")
    end
  end
end