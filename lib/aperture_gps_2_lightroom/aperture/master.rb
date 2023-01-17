# frozen_string_literal: true

module ApertureGps2Lightroom
  module Aperture
    class Master < Sequel::Model(APERTURE_DB[:rkmaster])
      one_to_many :versions, key: :masterUuid, primary_key: :uuid

      def compute_file_hash
        Digest::SHA1.file(APERTURE_MASTERS.join(imagePath)).hexdigest
      end
    end
  end
end
