require "rspec"

describe ImportService do
  let(:storage_service) { instance_double(StorageService) }

  context "when importing organisations" do
    subject(:import_service) { described_class.new(storage_service) }
    it "successfully create a new organisation if it does not exist" do
      import_service.update_organisations()
      # 1. call import with folder name
      # 2. check that it calls storage lists files
      # 3. check that it calls read file on each files
      # 4. create a temporary organisation object
      # 5. update/insert (upsert) organisation (settings?)
    end
  end
end
