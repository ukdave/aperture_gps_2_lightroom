# frozen_string_literal: true

require "sequel"
require "pathname"
require "yaml"

module ApertureGps2Lightroom
  class Config
    class << self
      attr_accessor :lightroom_images_path, :lightroom_image_hashes_file

      attr_reader :aperture_database_url, :aperture_db, :aperture_masters_path,
                  :lightroom_database_url, :lightroom_db

      def aperture_database_url=(url)
        @aperture_database_url = url
        @aperture_db = Sequel.connect(url)
      end

      def aperture_masters_path=(path)
        @aperture_masters_path = Pathname.new(path)
      end

      def lightroom_database_url=(url)
        @lightroom_database_url = url
        @lightroom_db = Sequel.connect(url)
      end

      # rubocop:disable Metrics/AbcSize
      def load(path)
        yaml = YAML.safe_load_file(path)
        self.aperture_database_url = yaml["aperture"]["database_url"]
        self.aperture_masters_path = yaml["aperture"]["masters_path"]
        self.lightroom_database_url = yaml["lightroom"]["database_url"]
        self.lightroom_images_path = yaml["lightroom"]["images_path"]
        self.lightroom_image_hashes_file = yaml["lightroom"]["image_hashes_file"]
        self
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
