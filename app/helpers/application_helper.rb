module ApplicationHelper
  POST_IMAGE_VARIANTS = {
    thumbnail: {
      resize_to_fill: [ 640, 360 ],
      format: :webp
    },
    main: {
      resize_to_limit: [ 1600, 1600 ],
      format: :webp
    },
    og: {
      resize_to_fill: [ 1200, 630 ],
      format: :jpg
    }
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

  def flash_visual(type)
    FLASH_VISUALS.fetch(type.to_s, FLASH_VISUALS.fetch("notice"))
  end

  def status_badge(level:, label:, icon:)
    tones = {
      success: "border-emerald-300 bg-emerald-50 text-emerald-700",
      warning: "border-amber-300 bg-amber-50 text-amber-800",
      error: "border-red-300 bg-red-50 text-red-700",
      info: "border-blue-200 bg-blue-50 text-blue-700"
    }
    tone = tones.fetch(level.to_sym, tones.fetch(:info))

    content_tag(:span, class: "inline-flex items-center gap-1.5 rounded-full border px-2 py-0.5 text-xs font-medium #{tone}") do
      safe_join([ ui_icon(icon, class_name: "h-3.5 w-3.5"), content_tag(:span, label) ])
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

  def ui_icon(name, class_name: "h-4 w-4")
    path_attrs = { "stroke-linecap": "round", "stroke-linejoin": "round" }
    paths = case name.to_sym
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
      [ tag.path(path_attrs.merge(d: "m21 8.25c0-2.485-2.015-4.5-4.5-4.5-1.74 0-3.248.99-4 2.438A4.484 4.484 0 0 0 8.5 3.75C6.015 3.75 4 5.765 4 8.25c0 4.025 4.5 7.5 8 10.5 3.5-3 8-6.475 8-10.5Z"))
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
    else
      [ tag.path(path_attrs.merge(d: "M12 6v6m0 4h.01M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z")) ]
    end

    content_tag(:svg, safe_join(paths), xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor", "stroke-width": "1.8", class: class_name, "aria-hidden": "true")
  end

  private

  def variant_options(key)
    POST_IMAGE_VARIANTS.fetch(key)
  rescue KeyError
    raise ArgumentError, "Unknown image variant: #{key.inspect}"
  end

  def default_image_tag_options(post, variant)
    base = {
      alt: post&.title.presence || t("images.desk_alt"),
      decoding: "async"
    }

    if variant == :thumbnail
      base.merge(loading: "lazy")
    else
      base.merge(loading: "eager", fetchpriority: "high")
    end
  end
end
