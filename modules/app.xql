xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/papyrillio/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/papyrillio/config" at "config.xqm";
import module namespace papy="http://www.papy" at "papy.xql";

import module namespace functx = "http://www.functx.com" at "functx-1.0-doc-2007-01.xq";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:indent "yes";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated). 
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

(: Ancient Authors And Works, e.g.

  DCLP TM No. 99590

:)

declare function app:ancientAuthorsAndWorks($node as node(), $model as map(*), $tlgAuthor as xs:string?, $tlgAuthorNumber as xs:string?, $tmWork as xs:string?, $tmWorkNumber as xs:string?) {

    let $collection := '/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes'
    let $biblio := if(string($tlgAuthor))then(  collection($collection)//tei:bibl[@type='publication'][@subtype='ancient'][tei:author=$tlgAuthor])else (
      if(string-length($tlgAuthorNumber)=4)then(collection($collection)//tei:bibl[@type='publication'][@subtype='ancient'][matches(tei:author/@ref, concat('(phi|tlg)', $tlgAuthorNumber, '( .+)?$'))])else(
      if(string($tmWork))then(                  collection($collection)//tei:bibl[@type='publication'][@subtype='ancient'][tei:title=$tmWork])else(
      if(string($tmWorkNumber))then(            collection($collection)//tei:bibl[@type='publication'][@subtype='ancient'][matches(tei:title/@ref, concat('authorwork/', $tmWorkNumber, '( .+)?$'))])else())))

    let $biblio    := $biblio[1]
    let $author    := normalize-space($biblio/tei:author[1])
    let $tlg       := replace(string-join($biblio/tei:author/@ref, ' '), '^.+(phi|tlg)(\d+)( .+)?$' , '$2')
    let $title     := normalize-space($biblio/tei:title[1])
    let $tm        := replace(string-join($biblio/tei:title/@ref, ' '), '^.+authorwork/(\d+)( .+)?$', '$1')
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
    </p>
};

declare function app:autocompleteAncientAuthorsAndWorks($node as node(), $model as map(*), $type as xs:string, $term as xs:string) {
    let $collection := '/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes'
    let $biblioList := if($type = 'author')then(collection($collection)//tei:bibl[@type='publication'][@subtype='ancient'][contains(tei:author, $term)])else (
      if($type = 'tlg')then(collection($collection)/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][tei:author/@ref[ends-with(., $term)]])else(
      if($type = 'title')then(collection($collection)//tei:bibl[@type='publication'][@subtype='ancient'][tei:title=$term])else(
      if($type = 'tm')then(collection($collection)/tei:TEI/tei:text[1]/tei:body[1]/tei:div[@type='bibliography'][@subtype='ancientEdition']/tei:listBibl[1]/tei:bibl[@type='publication'][@subtype='ancient'][tei:title/@ref[functx:substring-after-last(., '/')=$term]])else())))

    for $biblio in $biblioList
      group by $author := $biblio/tei:author, $title := $biblio/tei:title, $date := $biblio/tei:date
      return ($author, $title, $date)
};

declare function app:autocompleteAncientAuthors($node as node(), $model as map(*), $term as xs:string) {
    let $biblioList := collection('/db/data/idp.data/dclp/DCLP/?select=*.xml;recurse=yes')//tei:bibl[@type='publication'][@subtype='ancient'][contains(tei:author, $term)]
    for $biblio in $biblioList
      group by $author := $biblio/tei:author
      return <author><label>{string($author)}</label><ref>{data($author/@ref)}</ref></author>
};

(: example for HGV id that exists in EpiDoc but not in Aquila 3720b :)

declare function app:__searchEpiDocZombies($node as node(), $model as map(*)) {
    let $hgvIds := doc('/db/data/HGV/HGV_Id.xml')//id/text()
    let $hgvIds_flat := concat('|', string-join($hgvIds, '|'), '|')
    let $test := '|3720b|'
    let $in := if(contains($hgvIds_flat, $test))then('+')else('-')
    return <p>
    {$test}
    <br/>
    {$in}
    <br/>
    {$hgvIds_flat}
    </p>
};

declare function app:searchEpiDocZombies($node as node(), $model as map(*)) {
    let $hgvIds := doc('/db/data/HGV/HGV_Id.xml')//id/text()
    let $hgvIds_flat := concat('|', string-join($hgvIds, '|'), '|')
    for $doc in collection("/db/data/idp.data/dclp/HGV_meta_EpiDoc?select=*.xml;recurse=yes")[not(contains($hgvIds_flat, concat('|', normalize-space(tei:idno[@type='filename'][1]/text()), '|')))]
      let $hgvId_epidoc := string($doc/tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:publicationStmt[1]/tei:idno[@type='filename'][1])
      return
        <li>
        <a href="http://papyri.info/hgv/{$hgvId_epidoc}">{$hgvId_epidoc}</a>
        </li>
};

declare function app:_searchEpiDocZombies($node as node(), $model as map(*)) {
    let $hgvIds := doc('/db/data/HGV/HGV_Id.xml')
    for $doc in collection("/db/data/idp.data/dclp/HGV_meta_EpiDoc/?select=*.xml;recurse=yes")
      let $hgvId_epidoc  := string($doc/tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:publicationStmt[1]/tei:idno[@type='filename'][1])
      (:let $hasEquivalent = if($hgvIds//id[.=$hgvId])then('Hallo')else('xxxx'):)
      let $hgvId_filemaker := $hgvIds//id[.=$hgvId_epidoc][1]
      let $test := if($hgvId_filemaker = $hgvId_epidoc) then('') else ('!')
      return
        <li>
        <a href="http://papyri.info/hgv/{$hgvId_epidoc}">{$hgvId_epidoc}</a>/<a href="http://aquila.zaw.uni-heidelberg.de/hgv/{$hgvId_epidoc}">{$hgvId_epidoc}</a><span>{$test}</span>
        </li>
};

declare function app:autocomplete($node as node(), $model as map(*), $term as xs:string?) {
    if (string-length($term) > 3) then
        for $doc in collection("/db/data/idp.data/dclp/Biblio/?select=*.xml;recurse=yes")[contains(data(tei:bibl/tei:author), $term) or contains(data(tei:bibl/tei:title), $term)]
          let $space := '&#32;'
          let $id     := string($doc/tei:bibl/tei:idno[@type='pi'])
          let $author := normalize-space(string-join($doc/tei:bibl/tei:author[1]//text(), ' '))

          let $shortBp       := string($doc/tei:bibl/tei:note[@type='papyrological-series']/tei:title[@type='short-BP'])
          let $checklist     := string($doc/tei:bibl/tei:note[@type='papyrological-series']/tei:title[@type='short-Checklist'])
          let $titre         := string($doc/tei:bibl/tei:seg[@type='titre'])
          let $series        := string($doc/tei:bibl/tei:series/tei:title)
          let $standardMain  := string($doc/tei:bibl/tei:title[@type='main'][1])
          let $standardShort := string($doc/tei:bibl/tei:title[starts-with(@type, 'short')][1])
          let $title  := if(string($shortBp))then($shortBp)else(if(string($titre))then($titre)else(if(string($checklist))then($checklist)else(if(string($series))then($series)else(if(string($standardShort))then($standardShort)else(if(string($standardMain))then($standardMain)else())))))

          let $name   := concat('b', $id)
          let $content := concat($id, '. ', $author, if(string($author) and string($title))then(', ')else(), $title)
          return element {$name} {$content}
    else
    ()
};

declare function app:biblio($node as node(), $model as map(*), $search as xs:string?, $get as xs:integer?) {
    if (string-length($search) > 3) then
        for $doc in collection("/db/data/idp.data/dclp/Biblio/?select=*.xml;recurse=yes")[contains(data(tei:bibl/tei:author), $search) or contains(data(tei:bibl/tei:title), $search)]
          return <bibl>
              {$doc/tei:bibl/@xml:id, $doc/tei:bibl/@type, $doc/tei:bibl/@subtype, $doc/tei:bibl/tei:title[1], $doc/tei:bibl/tei:author[1], $doc/tei:bibl/tei:date[1]}
              </bibl>
    else
    (
        if($get) then
            doc(concat('/db/data/idp.data/dclp/Biblio/', papy:getFolder1000($get), '/', $get, '.xml'))/tei:bibl
        else
        ()
    )
};

declare function app:biblio-html($node as node(), $model as map(*), $search as xs:string?, $get as xs:integer?) {
    if (string-length($search) > 3) then
        for $doc in collection("/db/data/idp.data/dclp/Biblio/?select=*.xml;recurse=yes")[contains(data(tei:bibl/tei:author), $search) or contains(data(tei:bibl/tei:title), $search)]
          let $id     := string($doc/tei:bibl/tei:idno[@type='pi'])
          let $author := string-join(if($doc/tei:bibl/tei:author/tei:forename or $doc/tei:bibl/tei:author/tei:surname)then(concat($doc/tei:bibl/tei:author/tei:forename, '&#23;' ,$doc/tei:bibl/tei:author/tei:surname))else($doc/tei:bibl/tei:author), ' ')
          let $checklist := normalize-space($doc//tei:note[@type='papyrological-series'])
          let $title  := string-join($doc/tei:bibl/tei:title, ' = ')
          return papy:biblioToHtml($id, $author, if($checklist)then($checklist)else($title))
    else
    (
        if($get) then
            doc(concat('/db/data/idp.data/dclp/Biblio/', papy:getFolder1000($get), '/', $get, '.xml'))
        else
        ()
    )
};

declare function app:snippet($node as node(), $model as map(*), $biblio as xs:integer?, $ddb as xs:string?, $hgv as xs:string?, $dclp as xs:integer?) {
    if ($biblio) then
        let $epiDoc := doc(concat('/db/data/idp.data/dclp/Biblio/', papy:getFolder1000($biblio), '/', $biblio, '.xml'))
        let $author:= if($epiDoc/tei:bibl/tei:author[1])then(papy:flattenAuthor($epiDoc/tei:bibl/tei:author[1]))else(if($epiDoc/tei:bibl/tei:editor[1])then(papy:flattenAuthor($epiDoc/tei:bibl/tei:editor[1]))else())
        let $title := data($epiDoc/tei:bibl/tei:title[1])
        let $date := data($epiDoc/tei:bibl/tei:date[1])
        let $checklist := data($epiDoc/tei:bibl/tei:note[@type='papyrological-series']/tei:bibl/tei:title[@type='short-Checklist'])
        return
            <p id="b{$biblio}">
                <a href="http://papyri.info/biblio/{$biblio}" target="_blank" class="id">{$biblio}</a>.
                {
                    if(string($checklist))then(
                        <span class="title">{$checklist}</span>
                    )else(
                        <span>
                            <span class="author">{$author}</span>
                            {if($author and $title)then(', ')else()}
                            <span class="title">{$title}</span>
                            {if($date)then(<span> ({$date})</span>)else()}
                        </span>
                    )
                }
            </p>
    else
    (
        if($dclp) then
            doc(concat('/db/data/idp.data/dclp/DCLP/', papy:getFolder1000($dclp), '/', $dclp, '.xml'))
        else
        ()
    )
};