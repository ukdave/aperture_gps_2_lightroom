# frozen_string_literal: true

module ApertureGps2Lightroom
  module Aperture
    class Folder < Sequel::Model(APERTURE_DB[:rkfolder])
      one_to_many :versions, key: :projectUuid, primary_key: :uuid
    end
  end
end
