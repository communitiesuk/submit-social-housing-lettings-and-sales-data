require "rails_helper"

describe MandatoryCollectionResourcesService do
  let(:service) { described_class }

  describe "#generate_resource" do
    it "returns a CollectionResource object" do
      resource = service.generate_resource("lettings", 2024, "paper_form")
      expect(resource).to be_a(CollectionResource)
    end

    it "returns nil if resource type is not in the MANDATORY_RESOURCES list" do
      resource = service.generate_resource("lettings", 2024, "invalid_resource")
      expect(resource).to be_nil
    end

    it "returns a CollectionResource object with the correct attributes" do
      resource = service.generate_resource("lettings", 2024, "paper_form")
      expect(resource.resource_type).to eq("paper_form")
      expect(resource.display_name).to eq("lettings paper form (2024 to 2025)")
      expect(resource.short_display_name).to eq("Paper form")
      expect(resource.year).to eq(2024)
      expect(resource.log_type).to eq("lettings")
      expect(resource.download_filename).to eq("2024_25_lettings_paper_form.pdf")
    end
  end

  describe "#generate_resources" do
    it "generates all mandatory resources for given years" do
      resources = service.generate_resources("lettings", [2024, 2025])
      expect(resources[2024].map(&:resource_type)).to eq(%w[paper_form bulk_upload_template bulk_upload_specification])
      expect(resources[2025].map(&:resource_type)).to eq(%w[paper_form bulk_upload_template bulk_upload_specification])
    end
  end

  describe "#resources_per_year" do
    it "generates all mandatory resources for a specific year" do
      resources = service.resources_per_year(2024, "lettings")
      expect(resources.map(&:resource_type)).to eq(%w[paper_form bulk_upload_template bulk_upload_specification])
    end
  end
end
