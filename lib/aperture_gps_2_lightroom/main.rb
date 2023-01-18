# frozen_string_literal: true

require_relative "config"

ApertureGps2Lightroom::Config.load("config/config.yml")

require_relative "aperture"
require_relative "lightroom"

module ApertureGps2Lightroom
  class Main
    def self.go(aperture_project_name)
      # 1. Get Aperture versions in given project that have a GPS location
      aperture_versions = Aperture.versions_with_gps_for_project(aperture_project_name)
      puts "Found #{aperture_versions.length} versions with GPS in #{aperture_project_name}"

      # 2. Load/Generate static file with SHA1 hashes of all lightroom images
      lightroom_image_hashes = Lightroom.image_hashes

      # 3. Iterate over Aperture versions
      aperture_versions.each do |aperture_version|
        # 4. Find lightroom images with matching file hash
        lightroom_images = lightroom_image_hashes[aperture_version[:fileHash]]

        if lightroom_images.nil? || lightroom_images.empty?
          puts "WARNING: Can't find lightroom image for #{aperture_version}"
          next
        end

        # 5. Update lightroom image GPS
        lightroom_images.each do |lightroom_image|
          library_file = Lightroom::LibraryFile.full_path(lightroom_image).first

          if library_file.nil?
            puts "WARNING: Can't find DB library file for #{lightroom_image}"
            next
          end

          adobe_images = library_file.adobe_images
          if adobe_images.nil? || adobe_images.empty?
            puts "WARNING: Can't find DB adobe images for #{lightroom_image}"
            next
          end

          adobe_images.each do |adobe_image|
            harvested_exif_metadata = adobe_image.harvested_exif_metadata

            if harvested_exif_metadata.nil?
              puts "WARNING: Can't find DB metadate for #{lightroom_image} #{adobe_image.copyName}"
              next
            end

            if harvested_exif_metadata.gps?
              puts "WARNING: Cowardly refusing to overwrite GPS location for #{lightroom_image} #{adobe_image.copyName}"
              next
            end

            puts "Updating location for #{lightroom_image} #{adobe_image.copyName} to #{aperture_version[:latitude]}, #{aperture_version[:longitude]}"
            harvested_exif_metadata.update(hasGPS: 1, gpsSequence: 1, gpsLatitude: aperture_version[:latitude], gpsLongitude: aperture_version[:longitude])
          end
        end
      end
    end
  end
end
