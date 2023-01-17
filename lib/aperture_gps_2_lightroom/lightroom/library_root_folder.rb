# frozen_string_literal: true

module ApertureGps2Lightroom
  module Lightroom
    class LibraryRootFolder < Sequel::Model(LIGHTROOM_DB[:agLibraryRootFolder])
      one_to_many :library_folders, key: :rootFolder, primary_key: :id_local
    end
  end
end
