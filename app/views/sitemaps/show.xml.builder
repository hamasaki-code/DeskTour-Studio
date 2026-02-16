xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.lastmod Date.current.iso8601
    xml.changefreq "daily"
    xml.priority "1.0"
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
