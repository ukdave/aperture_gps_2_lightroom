# frozen_string_literal: true

module ApertureGps2Lightroom
  module Aperture
    class Master < Sequel::Model(Config.aperture_db[:rkmaster])
      one_to_many :versions, key: :masterUuid, primary_key: :uuid

      def compute_file_hash
        Digest::SHA1.file(Config.aperture_masters_path.join(imagePath)).hexdigest
      end
    end
  end
end
