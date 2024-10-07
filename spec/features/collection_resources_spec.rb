require "rails_helper"

RSpec.describe "Collection resources" do
  let(:user) { create(:user, :support) }

  before do
    allow(user).to receive(:need_two_factor_authentication?).and_return(false)
    sign_in user
  end

  context "when uploading paper form" do
    it "only allows pdf files for lettings" do
      visit("/collection-resources/lettings/2024/paper_form/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the paper form")
      expect(page).to have_content("Lettings 2024 to 2025")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).to have_content("The paper form must be a PDF.")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).not_to have_content("The paper form must be a PDF.")
    end

    it "only allows pdf files for sales" do
      visit("/collection-resources/sales/2024/paper_form/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the paper form")
      expect(page).to have_content("Sales 2024 to 2025")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).to have_content("The paper form must be a PDF.")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).not_to have_content("The paper form must be a PDF.")
    end
  end

  context "when uploading bu template" do
    it "only allows excel files for lettings" do
      visit("/collection-resources/lettings/2024/bulk_upload_template/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload template")
      expect(page).to have_content("Lettings 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload template must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload template must be a Microsoft Excel file.")
    end

    it "only allows excel files for sales" do
      visit("/collection-resources/sales/2024/bulk_upload_template/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload template")
      expect(page).to have_content("Sales 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload template must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload template must be a Microsoft Excel file.")
    end
  end

  context "when uploading bu specification" do
    it "only allows excel files for lettings" do
      visit("/collection-resources/lettings/2024/bulk_upload_specification/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload specification")
      expect(page).to have_content("Lettings 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload specification must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload specification must be a Microsoft Excel file.")
    end

    it "only allows excel files for sales" do
      visit("/collection-resources/sales/2024/bulk_upload_specification/edit")

      click_button("Save changes")

      expect(page).to have_content("Select which file to upload")

      expect(page).to have_content("Change the bulk upload specification")
      expect(page).to have_content("Sales 2024 to 2025")

      attach_file "file", file_fixture("pdf_file.pdf")
      click_button("Save changes")

      expect(page).to have_content("The bulk upload specification must be a Microsoft Excel file.")

      attach_file "file", file_fixture("excel_file.xlsx")
      click_button("Save changes")

      expect(page).not_to have_content("The bulk upload specification must be a Microsoft Excel file.")
    end
  end
end
