# This code interfaces with the EZID server
# and therefore implements parts of the EZID server
# API (http://ezid.cdlib.org/doc/apidoc.2.html)
# EZID API, Version 2

require 'net/http'
require 'nokogiri'

SCHEMES = { ark: 'ark:/', doi: 'doi:' }

IDENTIFIER_STATUS = { public: 'public',
                      reserved: 'reserved',
                      unavailable: 'unavailable' }

def get_identifier_metadata(identifier)
  request_uri = '/id/' + identifier
  uri = URI('https://ezid.cdlib.org' + request_uri)
  request = Net::HTTP::Get.new uri.request_uri
  response = call_api(uri, request)
end

def mint_identifier(shoulder,
                    identifier_status,
                    target_url = nil,
                    metadata = {},
                    identifier_type = :doi)
  # we only handle doi identifiers.
  return nil unless identifier_type == :doi
  # shoulder = 'doi:10.7916/D8'
  metadata['_target'] = target_url unless target_url.nil?
  metadata['_status'] = identifier_status
  request_uri = "/shoulder/#{shoulder}"
  uri = URI('https://ezid.cdlib.org' + request_uri)
  request = Net::HTTP::Post.new uri.request_uri
  response = call_api(uri, request, metadata)
end

def call_api(uri, request, request_data = nil)
  request.body = make_anvl(request_data) unless request_data.nil?
  
  request.basic_auth 'columbia', 'XXXXXXXXXXXXXX'
  request.add_field('Content-Type', 'text/plain; charset=UTF-8')
  result = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    response = http.request(request)
    response
  end
  result
end

def make_anvl(metadata)
  # fcd1, 08/31/16: Rubocop prefers a lambda instead of nested method definition
  # def escape(s)
  #   URI.escape(s, /[%:\n\r]/)
  #  end
  escape = -> (s) { URI.escape(s, /[%:\n\r]/) }
  anvl = ''
  metadata.each do |n, v|
    # fcd1, 08/31/16: code changes due to lambda instead of nested method defintion
    # anvl += escape(n.to_s) + ': ' + escape(v.to_s) + "\n"
    anvl += escape.call(n.to_s) + ': ' + escape.call(v.to_s) + "\n"
  end
  anvl.strip
end

def datacite_xml(
      doi = '10.0/00',      
      title = 'Default Title Value T',
      pub_year = '2018',
      date_created = '2018-12-4',
      date_modified = '2018-12-4',
      creators = [],
      subjects = [],
      editors = [],
      moderators = [],
      contributors = [],
      abstract = 'Default Abstract Value A'
    )
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.resource('xmlns' => 'http://datacite.org/schema/kernel-3',
                 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                 'xsi:schemaLocation' => 'http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd') do
      # required element, but not content
      # see http://ezid.cdlib.org/doc/apidoc.html#profile-datacite
      xml.identifier('identifierType' => 'DOI') { xml.text doi }
      add_title(xml, title)
      # required field
      xml.publisher 'Columbia University'
      # required field
      xml.publicationYear pub_year
      xml.dates do
        xml.date('dateType' => 'Created') { xml.text date_created }
        xml.date('dateType' => 'Updated') { xml.text date_modified }
      end
      add_creators(xml, creators)
      add_subjects(xml, subjects)
      add_contributors(xml, editors, moderators, contributors)
      add_resource_type xml
      xml.descriptions { xml.description('descriptionType' => 'Abstract') { xml.text abstract } }
      add_related_identifiers xml
    end
  end
  builder.to_xml
end

def add_title(xml, title)
  xml.titles { xml.title title }
end

# required field
def add_creators(xml, creators)
  if creators.empty?
    # required element, but not content
    # see http://ezid.cdlib.org/doc/apidoc.html#profile-datacite
    xml.creators { xml.creator { xml.creatorName '(:unav)' } }
  else
    xml.creators do
      creators.each do |name|
        xml.creator { xml.creatorName name }
      end
    end
  end
end

def add_subjects(xml, subjects)
  xml.subjects do
    subjects.each { |topic| xml.subject topic }
  end unless subjects.empty?
end

def add_contributors(xml, editors, moderators, contributors)
  return if (editors.empty? and moderators.empty? and contributors.empty?)
  xml.contributors do
    editors.each do |name|
      xml.contributor('contributorType' => 'Editor') { xml.contributorName name }
    end
    moderators.each do |name|
      xml.contributor('contributorType' => 'Other') { xml.contributorName name }
    end
    contributors.each do |name|
      xml.contributor('contributorType' => 'Other') { xml.contributorName name }
    end
  end
end

def add_resource_type(xml)
  xml.resourceType('resourceTypeGeneral' => 'Text') do
    xml.text 'Abstracts'
  end
end

def add_related_identifiers(xml)
  xml.relatedIdentifiers do
    xml.relatedIdentifier('relatedIdentifierType' => 'ISSN',
                          'relationType' => 'IsPartOf') { xml.text '1234567890' }
    xml.relatedIdentifier('relatedIdentifierType' => 'ISBN',
                          'relationType' => 'IsPartOf') { xml.text '9876543210' }
    xml.relatedIdentifier('relatedIdentifierType' => 'DOI',
                          'relationType' => 'IsVariantFormOf') { xml.text '10.0/00' }
  end
end
