# frozen_string_literal: true

require "digest"
require "sequel"

require_relative "aperture/folder"
require_relative "aperture/master"
require_relative "aperture/version"

module ApertureGps2Lightroom
  module Aperture
    def self.versions_with_gps_for_project(project_name)
      Aperture::Version.project_name(project_name).visible.with_gps.all.map do |version|
        { fileName: version.fileName,
          fileHash: version.master.compute_file_hash,
          latitude: version.exifLatitude,
          longitude: version.exifLongitude }
      end
    end
  end
end
