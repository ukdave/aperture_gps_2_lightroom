# frozen_string_literal: true

module ApertureGps2Lightroom
  module Lightroom
    class LibraryFile < Sequel::Model(LIGHTROOM_DB[:agLibraryFile])
      many_to_one :library_folder, key: :folder, primary_key: :id_local
      one_to_many :adobe_images, key: :rootFile, primary_key: :id_local

      def full_path
        "#{library_folder.library_root_folder.name}/#{library_folder.pathFromRoot}#{idx_filename}"
      end

      dataset_module do
        # rubocop:disable Layout/LineLength
        def full_path(path)
          select(Sequel.lit("agLibraryFile.*"))
            .join(:agLibraryFolder, id_local: :folder)
            .join(:agLibraryRootFolder, id_local: :rootFolder)
            .where(Sequel.lit("(agLibraryRootFolder.name || '/' || agLibraryFolder.pathFromRoot || agLibraryFile.idx_filename)") => path)
        end
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
