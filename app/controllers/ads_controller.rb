class AdsController < ApplicationController
  layout false

  def show
    lines = []
    publisher_id = ENV["ADSENSE_PUBLISHER_ID"].to_s.strip

    if publisher_id.present?
      lines << "google.com, pub-#{publisher_id.delete_prefix('pub-')}, DIRECT, f08c47fec0942fa0"
    else
      lines << "# DeskTour Studio ads.txt"
      lines << "# Set ADSENSE_PUBLISHER_ID to publish a Google AdSense line here."
    end

    render plain: lines.join("\n") + "\n", content_type: "text/plain"
  end
end
