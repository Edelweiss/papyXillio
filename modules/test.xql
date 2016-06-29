xquery version "3.0";


import module namespace functx = "http://www.functx.com" at "functx-1.0-doc-2007-01.xq";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:  :let $tlgAuthor := "Cleo", $tlgAuthorNumber := "", $tmWork := "", $tmWorkNumber := ""
let $collection := '/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes'
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
 collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[contains(.//tei:author, 'Ctesias')]
 collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[contains(.//tei:bibl[@type='publication'][@subtype='ancient']/tei:author, 'Ctesias')]
 collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')//tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]

 
 1s
 collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')//tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]
 collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')/tei:TEI/tei:text/tei:body/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]
 
 4s
 collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')//tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]
 
 ca. 31s
 collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][contains(.//tei:author, 'Ctesias')]
 
:)


collection('/db/apps/papyrillio/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')[contains(.//tei:bibl[@type='publication'][@subtype='ancient']/tei:title, 'Persika')]