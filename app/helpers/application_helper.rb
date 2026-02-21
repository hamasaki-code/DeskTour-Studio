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
    custom_description.presence || "Discover desk setup ideas and share your workspace on DeskTour Studio."
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
    "DeskTour Studio: #{post.title}"
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

  private

  def variant_options(key)
    POST_IMAGE_VARIANTS.fetch(key)
  rescue KeyError
    raise ArgumentError, "Unknown image variant: #{key.inspect}"
  end

  def default_image_tag_options(post, variant)
    base = {
      alt: post&.title.presence || "Desk image",
      decoding: "async"
    }

    if variant == :thumbnail
      base.merge(loading: "lazy")
    else
      base.merge(loading: "eager", fetchpriority: "high")
    end
  end
end
