require "fileutils"

module Storage
  class LocalDiskService < StorageService
    def list_files(folder = "/")
      path = Rails.root.join("tmp/storage", folder)
      Dir.entries(path)
    end

    def get_file(filename)
      path = Rails.root.join("tmp/storage", filename)

      File.open(path, "r").read
    end

    def get_file_io(filename)
      path = Rails.root.join("tmp/storage", filename)

      File.open(path, "r")
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def write_file(filename, data, content_type: nil)
      # rubocop:enable Lint/UnusedMethodArgument
      path = Rails.root.join("tmp/storage", filename)

      FileUtils.mkdir_p(path.dirname)

      File.open(path, "w") do |f|
        f.write data
      end
    end

    def get_file_metadata(filename)
      path = Rails.root.join("tmp/storage", filename)

      {
        "content_length" => File.size(path),
        "content_type" => MiniMime.lookup_by_filename(path.to_s)&.content_type || "application/octet-stream",
      }
    end

    def file_exists?(filename)
      path = Rails.root.join("tmp/storage", filename)

      File.exist?(path)
    end

    def delete_file(filename)
      path = Rails.root.join("tmp/storage", filename)

      File.delete(path)
    end
  end
end
