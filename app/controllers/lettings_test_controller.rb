require 'nokogiri'
require 'securerandom'
require 'fileutils'

class LettingsTestController < ApplicationController
  def index
    folder = '/Users/mohseeadmin/development-meta/CORE/CLDC-1222'
    stash_folder = Time.now.to_i.to_s
    generate_fixtures(folder, stash_folder, 50)

    
      LettingsLog.connection.truncate(LettingsLog.table_name)
    

    
     
    Imports::LettingsLogsImportService.new(Storage::S3Service).local_load("#{folder}/#{stash_folder}")

  end

  def node(xml_document, namespace, field)
    xml_document.at_xpath("//#{namespace}:#{field}")
  end  

  def generate_fixtures(folder, stash_folder, num_files)
    #folder = '/Users/mohseeadmin/development-meta/CORE/CLDC-1222/'
    canonical_logfiles = %w[canonical_logfile1.xml canonical_logfile2.xml canonical_logfile3.xml]
    
    
    FileUtils.mkdir_p("#{folder}/#{stash_folder}")
    
    (1..num_files).each do |i|
      xml_document = Nokogiri::XML(File.read("#{folder.chomp('/')}/#{canonical_logfiles.sample}"))
      document_id = node(xml_document, 'meta', 'document-id')
      new_guid = SecureRandom.uuid.to_s
      document_id.content = new_guid
    
      File.open("#{folder.chomp('/')}/#{stash_folder}/#{new_guid}.xml", 'w') { |f| f.puts xml_document }
    end
  end  
end
