xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @static_pages.each do |page|
    xml.url do
      xml.loc page[:loc]
      xml.lastmod page[:lastmod].iso8601
      xml.changefreq page[:changefreq]
      xml.priority page[:priority]
    end
  end

  @users.each do |user|
    xml.url do
      xml.loc user_url(user)
      xml.lastmod (user.updated_at || Date.current).to_date.iso8601
      xml.changefreq "weekly"
      xml.priority "0.6"
    end
  end

  @posts.each do |post|
    xml.url do
      xml.loc post_url(post)
      xml.lastmod post.updated_at.to_date.iso8601
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end
end
