# frozen_string_literal: true

require "digest"
require "pathname"
require "sequel"

APERTURE_DB = Sequel.connect("sqlite:///Volumes/Time%20Machine/Aperture%20Library%20(ready%20for%20migration).aplibrary/Database/apdb/Library.apdb")
APERTURE_MASTERS = Pathname.new("/Volumes/Time Machine/Aperture Library (ready for migration).aplibrary/Masters")

require_relative "aperture/folder"
require_relative "aperture/master"
require_relative "aperture/version"

module ApertureGps2Lightroom
  module Aperture
    def self.versions_with_gps_for_folder(folder_name)
      Aperture::Version.folder_name(folder_name).visible.with_gps.all.map do |version|
        { fileName: version.fileName,
          fileHash: version.master.compute_file_hash,
          latitude: version.exifLatitude,
          longitude: version.exifLongitude }
      end
    end
  end
end
