# frozen_string_literal: true

require "digest"
require "json"
require "sequel"

LIGHTROOM_DB = Sequel.connect("sqlite:///Users/david/Pictures/Lightroom%20Aperture/Lightroom%20Aperture.lrcat")
LIGHTROOM_IMAGES = Pathname.new("/Users/david/Pictures/Lightroom Aperture Photos")
LIGHTROOM_IMAGE_HASHES = "lightroom_image_hashes.json"

require_relative "lightroom/adobe_image"
require_relative "lightroom/harvested_exif_metadata"
require_relative "lightroom/library_file"
require_relative "lightroom/library_folder"
require_relative "lightroom/library_root_folder"

module ApertureGps2Lightroom
  module Lightroom
    def self.image_hashes
      return JSON.parse(File.read(LIGHTROOM_IMAGE_HASHES)) if File.exist?(LIGHTROOM_IMAGE_HASHES)

      compute_image_hashes.tap { |hashes| File.write(LIGHTROOM_IMAGE_HASHES, hashes.to_json) }
    end

    private_class_method def self.compute_image_hashes
      photos = Dir["#{LIGHTROOM_IMAGES}/**/*"].reject { |f| File.directory?(f) }
      photos.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |photo, hashes|
        hashes[Digest::SHA1.file(photo).hexdigest] << photo.delete_prefix("#{LIGHTROOM_IMAGES}/")
      end
    end
  end
end
