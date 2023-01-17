# frozen_string_literal: true

module ApertureGps2Lightroom
  module Aperture
    class Version < Sequel::Model(Config.aperture_db[:rkversion])
      many_to_one :master, key: :masterUuid, primary_key: :uuid
      many_to_one :folder, key: :projectUuid, primary_key: :uuid

      dataset_module do
        def folder_name(name)
          folder = Aperture::Folder.first(name:)
          raise "Folder not found: #{name}" unless folder

          where(projectUuid: folder.uuid)
        end

        def visible
          where(showInLibrary: 1)
        end

        def with_gps
          exclude(exifLatitude: nil).exclude(exifLongitude: nil)
        end
      end
    end
  end
end
