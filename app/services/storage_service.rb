class StorageService
  def list_files(_folder)
    raise NotImplementedError
  end

  def folder_present?(_folder)
    raise NotImplementedError
  end

  def get_file_io(_file_name)
    raise NotImplementedError
  end

  def write_file(_file_name, _data)
    raise NotImplementedError
  end
end
