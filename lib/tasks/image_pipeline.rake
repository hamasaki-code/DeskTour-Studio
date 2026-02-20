namespace :image do
  desc "Check image processing tooling for Active Storage (libvips/ImageMagick)"
  task doctor: :environment do
    command_available = lambda do |*command|
      system(*command, out: File::NULL, err: File::NULL)
    rescue StandardError
      false
    end

    vips_available = command_available.call("vips", "--version")
    image_magick_available = command_available.call("magick", "-version") || command_available.call("convert", "-version")
    processor = Rails.application.config.active_storage.variant_processor

    puts "Active Storage variant processor: #{processor}"
    puts "libvips available: #{vips_available}"
    puts "ImageMagick available: #{image_magick_available}"

    next if vips_available || image_magick_available

    abort("Neither libvips nor ImageMagick was detected. Install one image engine before using variants.")
  end
end
