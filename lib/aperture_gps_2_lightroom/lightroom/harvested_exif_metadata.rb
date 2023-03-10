# frozen_string_literal: true

module ApertureGps2Lightroom
  module Lightroom
    class HarvestedExifMetadata < Sequel::Model(Config.lightroom_db[:AgharvestedExifMetadata])
      one_to_one :adobe_image, key: :image, primary_key: :id_local

      def gps?
        !gpsLatitude.nil? && !gpsLongitude.nil?
      end
    end
  end
end
