class SitemapsController < ApplicationController
  layout false

  def show
    @posts = Post.visible.latest
    @users = User.joins(:posts).merge(Post.visible).distinct.order(updated_at: :desc)
    @static_pages = [
      { loc: root_url, lastmod: Date.current, changefreq: "daily", priority: "1.0" },
      { loc: gallery_url, lastmod: Date.current, changefreq: "daily", priority: "0.9" },
      { loc: users_url, lastmod: Date.current, changefreq: "weekly", priority: "0.7" },
      { loc: about_url, lastmod: Date.current, changefreq: "monthly", priority: "0.5" },
      { loc: support_url, lastmod: Date.current, changefreq: "monthly", priority: "0.5" },
      { loc: onboarding_url, lastmod: Date.current, changefreq: "monthly", priority: "0.5" },
      { loc: privacy_policy_url, lastmod: Date.current, changefreq: "yearly", priority: "0.3" },
      { loc: terms_url, lastmod: Date.current, changefreq: "yearly", priority: "0.3" },
      { loc: cookie_policy_url, lastmod: Date.current, changefreq: "yearly", priority: "0.3" }
    ]

    respond_to do |format|
      format.xml
    end
  end
end
