xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/papyrillio/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/papyrillio/config" at "config.xqm";
import module namespace papy="http://www.papy" at "papy.xql";

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

declare function app:helloworld($node as node(), $model as map(*), $name as xs:string?) {
    if ($name) then
        <p>Hello {$name}!</p>
    else
        ()
};

declare function app:autocomplete($node as node(), $model as map(*), $term as xs:string?) {
    if (string-length($term) > 3) then
        for $doc in collection("/db/apps/papyrillio/data/idp.data/dclp/Biblio/?select=*.xml;recurse=yes")[contains(data(tei:bibl/tei:author), $term) or contains(data(tei:bibl/tei:title), $term)]
          let $id     := string($doc/tei:bibl/tei:idno[@type='pi'])
          let $author := string-join(if($doc/tei:bibl/tei:author/tei:forename or $doc/tei:bibl/tei:author/tei:surname)then(concat($doc/tei:bibl/tei:author/tei:forename, '&#23;' ,$doc/tei:bibl/tei:author/tei:surname))else($doc/tei:bibl/tei:author), ' ')
          let $title  := string-join($doc/tei:bibl/tei:title, ' = ')
          let $name   := concat('b', $id)
          let $content := concat($id, '. ', $author, ', ', $title)
          return element {$name} {$title}
    else
    ()
};

declare function app:biblio($node as node(), $model as map(*), $search as xs:string?, $get as xs:integer?) {
    if (string-length($search) > 3) then
        for $doc in collection("/db/apps/papyrillio/data/idp.data/dclp/Biblio/?select=*.xml;recurse=yes")[contains(data(tei:bibl/tei:author), $search) or contains(data(tei:bibl/tei:title), $search)]
          return <bibl>
              {$doc/tei:bibl/@xml:id, $doc/tei:bibl/@type, $doc/tei:bibl/@subtype, $doc/tei:bibl/tei:title[1], $doc/tei:bibl/tei:author[1], $doc/tei:bibl/tei:date[1]}
              </bibl>
    else
    (
        if($get) then
            doc(concat('/db/apps/papyrillio/data/idp.data/dclp/Biblio/', papy:getFolder1000($get), '/', $get, '.xml'))/tei:bibl
        else
        ()
    )
};

declare function app:biblio-html($node as node(), $model as map(*), $search as xs:string?, $get as xs:integer?) {
    if (string-length($search) > 3) then
        for $doc in collection("/db/apps/papyrillio/data/idp.data/dclp/Biblio/?select=*.xml;recurse=yes")[contains(data(tei:bibl/tei:author), $search) or contains(data(tei:bibl/tei:title), $search)]
          let $id     := string($doc/tei:bibl/tei:idno[@type='pi'])
          let $author := string-join(if($doc/tei:bibl/tei:author/tei:forename or $doc/tei:bibl/tei:author/tei:surname)then(concat($doc/tei:bibl/tei:author/tei:forename, '&#23;' ,$doc/tei:bibl/tei:author/tei:surname))else($doc/tei:bibl/tei:author), ' ')
          let $title  := string-join($doc/tei:bibl/tei:title, ' = ')
          return papy:biblioToHtml($id, $author, $title)
    else
    (
        if($get) then
            doc(concat('/db/apps/papyrillio/data/idp.data/dclp/Biblio/', papy:getFolder1000($get), '/', $get, '.xml'))
        else
        ()
    )
};

declare function app:snippet($node as node(), $model as map(*), $biblio as xs:integer?, $ddb as xs:string?, $hgv as xs:string?, $dclp as xs:integer?) {
    if ($biblio) then
        let $epiDoc := doc(concat('/db/apps/papyrillio/data/idp.data/dclp/Biblio/', papy:getFolder1000($biblio), '/', $biblio, '.xml'))
        let $author := if($epiDoc/tei:bibl/tei:author[1])then(papy:flattenAuthor($epiDoc/tei:bibl/tei:author[1]))else(if($epiDoc/tei:bibl/tei:editor[1])then(papy:flattenAuthor($epiDoc/tei:bibl/tei:editor[1]))else())
        let $title  := data($epiDoc/tei:bibl/tei:title[1])
        let $date   := data($epiDoc/tei:bibl/tei:date[1])
        return
            <p id="b{$biblio}">
                <a href="http://papyri.info/biblio/{$biblio}" target="_blank" class="id">{$biblio}</a>.
                <span class="author">{$author}</span>
                {if($author and $title)then(', ')else()}
                <span class="title">{$title}</span>
                {if($date)then(<span> ({$date})</span>)else()}
            </p>
    else
    (
        if($dclp) then
            doc(concat('/db/apps/papyrillio/data/idp.data/dclp/Biblio/', papy:getFolder1000($dclp), '/', $dclp, '.xml'))
        else
        ()
    )
};