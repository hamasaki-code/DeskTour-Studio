command_available = lambda do |*command|
  system(*command, out: File::NULL, err: File::NULL)
rescue StandardError
  false
end

configured_processor = ENV["ACTIVE_STORAGE_VARIANT_PROCESSOR"]&.to_sym

if configured_processor
  Rails.application.config.active_storage.variant_processor = configured_processor
else
  vips_available = command_available.call("vips", "--version")
  image_magick_available = command_available.call("magick", "-version") || command_available.call("convert", "-version")

  selected_processor = vips_available ? :vips : :mini_magick
  Rails.application.config.active_storage.variant_processor = selected_processor

  Rails.logger.info("[image-pipeline] variant processor=#{selected_processor} vips=#{vips_available} imagemagick=#{image_magick_available}")
  Rails.logger.warn("[image-pipeline] no image engine detected (libvips/ImageMagick). Variants will fail at runtime.") unless vips_available || image_magick_available
end
