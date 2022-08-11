class ArchiveStorageService < StorageService
  MAX_SIZE = 50 * (1024**2) # 50MiB

  def initialize(archive_io)
    super()
    @archive = Zip::File.open_buffer(archive_io)
  end

  def list_files(folder)
    @archive.glob(File.join(folder, "*.*"))
            .map(&:name)
  end

  def folder_present?(folder)
    !list_files(folder).empty?
  end

  def get_file_io(file_name)
    entry = @archive.get_entry(file_name)
    raise "File too large to be extracted" if entry.size > MAX_SIZE

    entry.get_input_stream
  end
end
