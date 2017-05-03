xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace file = "http://exist-db.org/xquery/file";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare option output:method "text";


(:

file:exists('/Users/elemmire/data/idp.data/dclp/development/Biblio/1/1.xml')
file:list('/Users/elemmire/data/idp.data/dclp/dclp')
file:sync('/db/data/idp.data/dclp/DCLP/1', '/Users/elemmire/data/idp.data/dclp/development/DCLP/1', ())
=> copies files from server to system path

collections
xmldb:collection-available('/db/data/idp.data/dclp/HGV_trans_EpiDoc')
xmldb:get-child-collections('/db/data/idp.data/dclp/')
xmldb:match-collection('^.*data.*$')

resources
xmldb:copy('/db/data/idp.data/dclp/HGV_trans_EpiDoc', '/db/data/', 'glossary.xml')
xmldb:created('/db/data/idp.data/dclp/HGV_trans_EpiDoc', 'glossary.xml')
xmldb:last-modified('/db/data/idp.data/dclp/HGV_trans_EpiDoc', 'glossary.xml')
xmldb:document('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml')
concat(xmldb:size('/db/data/', 'glossary.xml') div 1000, 'MB')
xmldb:rename('/db/data/', 'glossary.xml', 'glossary2.xml')
xmldb:remove('/db/data', 'glossary2.xml')
xmldb:store('/db/data/', 'glossaryNew.xml', xmldb:document('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml'), 'xml')

import idp.data
xmldb:remove('/db/data/idp.data/dclp/DCLP')
xmldb:create-collection('/db/data', 'tmp')
xmldb:store-files-from-pattern('/db/data/idp.data/dclp', '/Users/elemmire/data/idp.data/dclp/dclp', 'DCLP/*/*.xml', 'text/xml', true())
xmldb:store-files-from-pattern('/db/data/idp.data/dclp', '/Users/elemmire/data/idp.data/dclp/dclp', 'HGV_trans_EpiDoc/*.xml', 'text/xml', true())
:)

(:
/data/idp.data/dclp/Biblio/1/1.xml


:)


let $list := file:list('/Users/elemmire/data/idp.data/dclp/development/DDB_EpiDoc_XML/cpr')/file:directory[starts-with('cpr.17A.AnhangA', @name)]/@name
  return $list[not(string-length(.) < $list/string-length(.))]

