# frozen_string_literal: true

module ApertureGps2Lightroom
  module Lightroom
    class LibraryFolder < Sequel::Model(LIGHTROOM_DB[:agLibraryFolder])
      many_to_one :library_root_folder, key: :rootFolder, primary_key: :id_local
      one_to_many :library_files, key: :folder, primary_key: :id_local
    end
  end
end
