# frozen_string_literal: true

module ApertureGps2Lightroom
  module Lightroom
    class AdobeImage < Sequel::Model(Config.lightroom_db[:Adobe_images])
      many_to_one :library_file, key: :rootFile, primary_key: :id_local
      one_to_one :harvested_exif_metadata, key: :image, primary_key: :id_local
    end
  end
end
