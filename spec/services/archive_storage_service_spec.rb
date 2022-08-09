require "rails_helper"

RSpec.describe ArchiveStorageService do
  subject(:archive_service) { described_class.new(archive_content) }

  let(:compressed_folder) { "my_directory" }
  let(:compressed_filename) { "hello.txt" }
  let(:compressed_filepath) { File.join(compressed_folder, compressed_filename) }
  let(:compressed_file) do
    file = Tempfile.new
    file << "Hello World\n"
    file.rewind
    file
  end
  let(:archive_content) do
    zip_file = Zip::File.open_buffer(StringIO.new)
    zip_file.mkdir(compressed_folder)
    zip_file.add(compressed_filepath, compressed_file)
    zip_file.write_buffer
  end

  describe "#list_files" do
    it "returns the list of files present in an existing folder" do
      file_list = archive_service.list_files(compressed_folder)
      expect(file_list).to contain_exactly(compressed_filepath)
    end

    it "returns an empty file list for an unknown folder" do
      file_list = archive_service.list_files("random_folder")
      expect(file_list).to be_empty
    end
  end

  describe "#folder_present?" do
    it "returns true if a folder in the archive exists" do
      presence = archive_service.folder_present?(compressed_folder)
      expect(presence).to be_truthy
    end

    it "returns false if a folder in the archive does not exist" do
      presence = archive_service.folder_present?("random_folder")
      expect(presence).to be_falsey
    end
  end

  describe "#get_file_io" do
    it "returns the file content if a file exists" do
      content = archive_service.get_file_io(compressed_filepath)
      expect(content.read).to eq(compressed_file.read)
    end

    it "raises an error if the file exists but is too large" do
      archive = archive_service.instance_variable_get(:@archive)
      allow(archive).to receive(:get_entry).and_return(Zip::Entry.new(nil, "", nil, nil, nil, nil, nil, 100_000_000, nil))

      expect { archive_service.get_file_io(compressed_filepath) }
        .to raise_error(RuntimeError, "File too large to be extracted")
    end

    it "raises an error of a file does not exist" do
      expect { archive_service.get_file_io("random.zzz") }
        .to raise_error(Errno::ENOENT)
    end
  end
end
