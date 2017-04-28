xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace example = "http://exist-db.org/xquery/examples";
declare namespace file = "http://exist-db.org/xquery/file";

declare option output:method "text";
(:  :let $tlgAuthor := "Cleo", $tlgAuthorNumber := "", $tmWork := "", $tmWorkNumber := ""
let $collection := '/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes'
let $biblio := if(string($tlgAuthor))then(collection($collection)/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][tei:author[.=$tlgAuthor]][1])else (
  if(string-length($tlgAuthorNumber)=4)then(collection($collection)/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][tei:author/@ref[ends-with(., $tlgAuthorNumber)]][1])else(
  if(string($tmWork))then(collection($collection)/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][tei:title[.=$tmWork]][1])else(
  if(string($tmWorkNumber))then(collection($collection)/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][tei:title/@ref[functx:substring-after-last(., '/')=$tmWorkNumber]][1])else())))

let $author    := normalize-space($biblio/tei:author[1])
let $tlg       := functx:substring-after-last($biblio/tei:author/@ref, 'tlg')
let $title     := normalize-space($biblio/tei:title[1])
let $tm        := functx:substring-after-last($biblio/tei:title/@ref, '/')
let $date      := string($biblio/tei:date)
let $authorRef := string($biblio/tei:author/@ref)
let $workRef   := string($biblio/tei:title/@ref)

let $space := '&#32;'

return <p>
[TLG Author: {$tlgAuthor}/ TLG Author Number: {$tlgAuthorNumber} / TM Work: {$tmWork} /  TM Work Number: {$tmWorkNumber}]<br/>
<b>TLG:</b>{$space}{$tlg}<br/>
<b>Author:</b>{$space}{$author}<br/>
<b>Author ref:</b>{$space}{$authorRef}<br/>
<b>TM:</b>{$space}{$tm}<br/>
<b>Title:</b>{$space}{$title}<br/>
<b>Work ref:</b>{$space}{$workRef}<br/>
<b>Date:</b>{$space}{$date}<br/>
</p>:)

(: 

 < 1s
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[contains(.//tei:author, 'Ctesias')]
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[contains(.//tei:bibl[@type='publication'][@subtype='ancient']/tei:author, 'Ctesias')]
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')//tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]

 
 1s
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')//tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')/tei:TEI/tei:text/tei:body/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]
 
 4s
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')//tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]
 
 ca. 31s
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]

 => BEST
 collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[contains(.//tei:bibl[@type='publication'][@subtype='ancient']/tei:title, 'Persika')] 

:)

(: 
Finde Dateien mit mehreren illustrations und online resources
collection('/data/idp.data/dclp_hd/DCLP/?select=*.xml;recurse=yes')[count(.//tei:div[@subtype='illustrations']/tei:listBibl/tei:bibl[tei:ptr]) > 1][count(.//tei:bibl[@type='illustration']) > 1][count(.//tei:bibl[@type='publication'][@subtype='principal']) > 1]
:)

(:
Abragen auf ancient work and ancient author
collection('/data/idp.data/dclp_hd/DCLP?select=*.xml;recurse=yes')[count(.//tei:div[@subtype='ancientEdition']//tei:bibl) > 1][.//tei:div[@subtype='ancientEdition']//tei:author/@ref][.//tei:div[@subtype='ancientEdition']//tei:certainty]
:)

(:

Finde alle languages

<div>{
for $lang in fn:distinct-values(collection('/data/idp.data/dclp_hd/DCLP?select=*.xml;recurse=yes')//tei:div[@type='edition']/@xml:lang)
  return data($lang)
}</div>
:)

(:

Für Holger:

Liste aller Dateien
in DCLP außer den herkulanischen Papyri, die sowohl bereits Text als
auch mindestens einen link in
//custEvent/graphic/@url
haben.

Vorabfragen:

collection('/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[not(starts-with(.//tei:titleStmt/tei:title, 'P.Herc.'))]
collection('/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[string(string-join(.//tei:div[@type='edition'], ''))]
collection('/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[.//tei:custEvent/tei:graphic/@url]

Finale Abfrage:

let $nl := "&#10;"
for $tm in collection('/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[not(starts-with(.//tei:titleStmt/tei:title, 'P.Herc.'))][string(string-join(.//tei:div[@type='edition'], ''))][.//tei:custEvent/tei:graphic/@url]//tei:idno[@type='TM']
return concat('https://github.com/DCLP/idp.data/blob/dclp/DCLP/', ceiling(number($tm) div 1000), '/', $tm, '.xml', $nl)
 :)


(:
 : Alle
let $nl := "&#10;"
let $newline := '&#13;&#10;'
for $biblio in collection('/data/idp.data/dclp/DCLP?select=*.xml;recurse=yes')//tei:div[@subtype='principalEdition']//tei:bibl[not(tei:ptr/@target)]
return concat($biblio/tei:title, ' ', $biblio/tei:biblScope[@unit='volume'], '|')

 : Einzelne
let $nl := "&#10;"
let $newline := '&#13;&#10;'
for $biblio in collection('/data/idp.data/dclp/DCLP?select=*.xml;recurse=yes')//tei:div[@subtype='principalEdition']//tei:bibl[not(tei:ptr/@target)][tei:title='P. Yale']
return concat($biblio/tei:title, ' ', $biblio/tei:biblScope[@unit='volume'], ' ', string-join($biblio/tei:biblScope[not(@unit='volume')], ' '), '|')
:)


for $item in collection('/db/data/idp.data/dclp/DCLP?select=*.xml;recurse=yes')[starts-with(.//tei:idno[@type='dclp-hybrid'], 'na')][starts-with(.//tei:bibl[@type='printed'], 'ZPE')]
  return string($item//tei:idno[@type='TM'])