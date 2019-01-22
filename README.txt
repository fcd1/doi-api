PLEASE NOTE: These are quick and dirty usage notes, basically cut-and-paste snippets from actual sessions that occured in December 2018.
It is possible code may have changed since, but the info below should still be of value.
Also, some of the examples below may show the EZID api url instead of the DataCite url, but besides that one difference the usage will be the same.

Example of getting an existing DOI:

;-) irb 
2.4.1 :001 > require('./doi_api.rb')
 => true 
2.4.1 :002 > get_identifier_metadata('doi:10.7916/D8TX3FZV')
 => #<Net::HTTPOK 200 OK readbody=true> 
2.4.1 :003 > puts get_identifier_metadata('doi:10.7916/D8TX3FZV')
#<Net::HTTPOK:0x00556fb9ae32f0>
 => nil 
2.4.1 :004 > puts get_identifier_metadata('doi:10.7916/D8TX3FZV').body
success: doi:10.7916/D8TX3FZV
_updated: 1532636696
_target: https://dlc.library.columbia.edu/durst/cul:bg79cnp5pv
datacite: <?xml version="1.0"?>%0A<resource xmlns="http://datacite.org/schema/kernel-3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd">%0A  <identifier identifierType="DOI">10.7916/D8TX3FZV</identifier>%0A  <titles>%0A    <title>The "400" Restaurant Fifth Ave. at 43rd St., New York City Presents Benny Goodman</title>%0A  </titles>%0A  <publisher>Columbia University</publisher>%0A  <publicationYear>2015</publicationYear>%0A  <dates>%0A    <date dateType="Created">2015-02-04</date>%0A    <date dateType="Updated">2018-07-26</date>%0A  </dates>%0A  <creators>%0A    <creator>%0A      <creatorName>(:unav)</creatorName>%0A    </creator>%0A  </creators>%0A  <subjects>%0A    <subject>Interiors</subject>%0A  </subjects>%0A  <descriptions>%0A    <description descriptionType="Abstract">Primary subject: Benny Goodman Playing the Clarinet</description>%0A  </descriptions>%0A</resource>
_profile: datacite
_export: yes
_owner: columbia
_shadowedby: ark:/b7916/d8tx3fzv
_ownergroup: columbia
_created: 1485415996
_status: public
_datacenter: CDL.CULIS
 => nil 
2.4.1 :005 >

Example of minting a reserved DOI:

2.4.1 :004 > puts mint_identifier('doi:10.7916/D8','reserved','https://ezid.cdlib.org/doc/apidoc.html').body
success: doi:10.7916/D8WT0B83 | ark:/b7916/d8wt0b83
 => nil 
2.4.1 :005 >

Create a metadata xml to be sent when creating a public DOI. Metadata is hard coded in method, just to be used for testing:

2.4.1 :001 > require('./doi_api.rb')
 => true 
2.4.1 :002 > datacite_xml
<?xml version="1.0"?>
<resource xmlns="http://datacite.org/schema/kernel-3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd">
  <identifier identifierType="DOI">10.0/00</identifier>
  <titles>
    <title>Default Title Value T</title>
  </titles>
  <publisher>Columbia University</publisher>
  <publicationYear>2018</publicationYear>
  <dates>
    <date dateType="Created">2018-12-4</date>
    <date dateType="Updated">2018-12-4</date>
  </dates>
  <creators>
    <creator>
      <creatorName>(:unav)</creatorName>
    </creator>
  </creators>
  <resourceType resourceTypeGeneral="Text">Abstracts</resourceType>
  <descriptions>
    <description descriptionType="Abstract">Default Abstract Value A</description>
  </descriptions>
  <relatedIdentifiers>
    <relatedIdentifier relatedIdentifierType="ISSN" relationType="IsPartOf">1234567890</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="ISBN" relationType="IsPartOf">9876543210</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="IsVariantFormOf">10.0/00</relatedIdentifier>
  </relatedIdentifiers>
</resource>
 => nil 
2.4.1 :003 >

Mint public DOI, supplying metadata (not actual metadata, just bogus to get test API call to work)

2.4.1 :005 >   metadata_hash = { datacite: datacite_xml }
 => {:datacite=>"<?xml version=\"1.0\"?>\n<resource xmlns=\"http://datacite.org/schema/kernel-3\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd\">\n  <identifier identifierType=\"DOI\">10.0/00</identifier>\n  <titles>\n    <title>Default Title Value T</title>\n  </titles>\n  <publisher>Columbia University</publisher>\n  <publicationYear>2018</publicationYear>\n  <dates>\n    <date dateType=\"Created\">2018-12-4</date>\n    <date dateType=\"Updated\">2018-12-4</date>\n  </dates>\n  <creators>\n    <creator>\n      <creatorName>(:unav)</creatorName>\n    </creator>\n  </creators>\n  <resourceType resourceTypeGeneral=\"Text\">Abstracts</resourceType>\n  <descriptions>\n    <description descriptionType=\"Abstract\">Default Abstract Value A</description>\n  </descriptions>\n  <relatedIdentifiers>\n    <relatedIdentifier relatedIdentifierType=\"ISSN\" relationType=\"IsPartOf\">1234567890</relatedIdentifier>\n    <relatedIdentifier relatedIdentifierType=\"ISBN\" relationType=\"IsPartOf\">9876543210</relatedIdentifier>\n    <relatedIdentifier relatedIdentifierType=\"DOI\" relationType=\"IsVariantFormOf\">10.0/00</relatedIdentifier>\n  </relatedIdentifiers>\n</resource>\n"} 
2.4.1 :006 > puts mint_identifier('doi:10.33520','public','https://ezid.cdlib.org/doc/apidoc.html',metadata_hash).body
success: doi:10.33520/yymm-n121
_target: https://ezid.cdlib.org/doc/apidoc.html
datacite: <?xml version="1.0" encoding="UTF-8"?>%0A<resource xmlns="http://datacite.org/schema/kernel-3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd">%0A  <identifier identifierType="DOI">10.33520/YYMM-N121</identifier>%0A  <titles>%0A    <title>Default Title Value T</title>%0A  </titles>%0A  <publisher>Columbia University</publisher>%0A  <publicationYear>2018</publicationYear>%0A  <dates>%0A    <date dateType="Created">2018-12-4</date>%0A    <date dateType="Updated">2018-12-4</date>%0A  </dates>%0A  <creators>%0A    <creator>%0A      <creatorName>(:unav)</creatorName>%0A    </creator>%0A  </creators>%0A  <resourceType resourceTypeGeneral="Text">Abstracts</resourceType>%0A  <descriptions>%0A    <description descriptionType="Abstract">Default Abstract Value A</description>%0A  </descriptions>%0A  <relatedIdentifiers>%0A    <relatedIdentifier relatedIdentifierType="ISSN" relationType="IsPartOf">1234567890</relatedIdentifier>%0A    <relatedIdentifier relatedIdentifierType="ISBN" relationType="IsPartOf">9876543210</relatedIdentifier>%0A    <relatedIdentifier relatedIdentifierType="DOI" relationType="IsVariantFormOf">10.0/00</relatedIdentifier>%0A  </relatedIdentifiers>%0A</resource>
_profile: datacite
_datacenter: DEMO.CUL
_export: yes
_created: 1543967555
_updated: 1543967555
_status: public
 => nil 
2.4.1 :007 > 
