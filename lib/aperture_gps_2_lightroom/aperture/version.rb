# frozen_string_literal: true

module ApertureGps2Lightroom
  module Aperture
    class Version < Sequel::Model(Config.aperture_db[:rkversion])
      many_to_one :master, key: :masterUuid, primary_key: :uuid
      many_to_one :folder, key: :projectUuid, primary_key: :uuid

      dataset_module do
        def project_name(name)
          project = Aperture::Folder.first(name:, folderType: 2)
          raise "Project not found: #{name}" unless project

          where(projectUuid: project.uuid)
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
