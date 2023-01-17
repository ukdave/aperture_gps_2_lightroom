# frozen_string_literal: true

require "digest"
require "json"
require "sequel"

require_relative "lightroom/adobe_image"
require_relative "lightroom/harvested_exif_metadata"
require_relative "lightroom/library_file"
require_relative "lightroom/library_folder"
require_relative "lightroom/library_root_folder"

module ApertureGps2Lightroom
  module Lightroom
    def self.image_hashes
      return JSON.parse(File.read(Config.lightroom_image_hashes_file)) if File.exist?(Config.lightroom_image_hashes_file)

      compute_image_hashes.tap { |hashes| File.write(Config.lightroom_image_hashes_file, hashes.to_json) }
    end

    private_class_method def self.compute_image_hashes
      photos = Dir["#{Config.lightroom_images_path}/**/*"].reject { |f| File.directory?(f) }
      photos.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |photo, hashes|
        hashes[Digest::SHA1.file(photo).hexdigest] << photo.delete_prefix("#{Config.lightroom_images_path}/")
      end
    end
  end
end
