module ApplicationHelper
  def page_title(custom_title = nil)
    base = "DeskTour Studio"
    return base if custom_title.blank?

    "#{custom_title} | #{base}"
  end

  def meta_description(custom_description = nil)
    custom_description.presence || "世界中のクリエイター・エンジニアの作業環境を共有できるデスク構成ギャラリー。"
  end

  def canonical_url
    request.base_url + request.path
  end

  def og_image_url(post = nil)
    if post&.desk_image&.attached?
      url_for(post.desk_image)
    else
      image_url("icon.png")
    end
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
end
