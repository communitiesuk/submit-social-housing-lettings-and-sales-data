require "fileutils"

module Storage
  class LocalDiskService < StorageService
    def list_files(folder = "/")
      path = Rails.root.join("tmp/storage", folder)
      Dir.entries(path)
    end

    def get_file_io(filename)
      path = Rails.root.join("tmp/storage", filename)

      File.open(path, "r")
    end

    def write_file(filename, data)
      path = Rails.root.join("tmp/storage", filename)

      FileUtils.mkdir_p(path.dirname)

      File.open(path, "w") do |f|
        f.write data
      end
    end
  end
end
