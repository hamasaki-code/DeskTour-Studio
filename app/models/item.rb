require "uri"

class Item < ApplicationRecord
  belongs_to :post

  before_validation :append_affiliate_tag

  validates :name, presence: true, length: { maximum: 100 }
  validates :affiliate_url, length: { maximum: 1000 }, allow_blank: true
  validate :affiliate_url_format

  private

  def append_affiliate_tag
    return if affiliate_url.blank?
    return if ENV["AMAZON_AFFILIATE_TAG"].blank?

    uri = URI.parse(affiliate_url)
    return unless uri.host&.include?("amazon.")

    query_hash = URI.decode_www_form(uri.query.to_s).to_h
    query_hash["tag"] = ENV["AMAZON_AFFILIATE_TAG"]
    uri.query = URI.encode_www_form(query_hash)
    self.affiliate_url = uri.to_s
  rescue URI::InvalidURIError
    nil
  end

  def affiliate_url_format
    return if affiliate_url.blank?

    uri = URI.parse(affiliate_url)
    return if uri.is_a?(URI::HTTP) && uri.host.present?

    errors.add(:affiliate_url, "は有効なURLを入力してください")
  rescue URI::InvalidURIError
    errors.add(:affiliate_url, "は有効なURLを入力してください")
  end
end
