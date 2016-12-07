xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace util = 'http://exist-db.org/xquery/util';
declare option output:method "html5";
declare option output:media-type "text/html";

(:

sample url

http://localhost:8080/exist/rest/db/apps/papyrillio/biblio/searchTitles.xq?regExp=Prag&type=journal

:)

<html>
    <head>
        <title>Biblio - Search Titles</title>
        <style type="text/css">
            label {{ width: 120px; display: block; float: left; }}
        </style>
    </head>
<body>
<h1>Biblio - Search Titles</h1>

<form action="#" method="get">
<fieldset>
    <legend>Regular Expression (e.g. 'Prag[ue]')</legend>
    <input type="text" name="regExp" required="required" value="{request:get-parameter('regExp', (''))}"/>
    {
        if(request:get-parameter('type', 'book') = 'book')then(
            <input type="radio" name="type" value="book" checked="checked">book</input>
        )else(
            <input type="radio" name="type" value="book">book</input>
        )
    }
    {
        if(request:get-parameter('type', 'book') = 'article')then(
            <input type="radio" name="type" value="article" checked="checked">article</input>
        )else(
            <input type="radio" name="type" value="article">article</input>
        )
    }
    {
        if(request:get-parameter('type', 'book') = 'review')then(
            <input type="radio" name="type" value="review" checked="checked">review</input>
        )else(
            <input type="radio" name="type" value="review">review</input>
        )
    }
    {
        if(request:get-parameter('type', 'book') = 'journal')then(
            <input type="radio" name="type" value="journal" checked="checked">journal</input>
        )else(
            <input type="radio" name="type" value="journal">journal</input>
        )
    }
    <input type="submit" value="search"/>
</fieldset>
</form>

<ul>
{
  let $regExp := request:get-parameter('regExp', 'P.Köln 1')
  let $type := request:get-parameter('type', 'book')
  let $space := '&#32;'
  for $biblio in collection('/data/idp.data/dclp/Biblio?select=*.xml;recurse=yes')[./tei:bibl/@type=$type][matches(string-join((./tei:bibl/tei:title, ./tei:bibl/tei:series/tei:title, ./tei:bibl/tei:note[@type='papyrological-series']/tei:bibl/tei:title), ' '), $regExp)]
    let $id := substring-after(string($biblio/tei:bibl/@xml:id), 'b')
    let $typeSubtype := concat($biblio/tei:bibl/@type, if($biblio/tei:bibl/@subtype)then(concat('-', $biblio/tei:bibl/@subtype))else())
    let $titles := string-join($biblio/tei:bibl/tei:title||$biblio/tei:bibl/tei:series/tei:title, ' | ')
    return
      <li>
        <a href="https://github.com/DCLP/idp.data/blob/dclp/Biblio/{ceiling(number($id) div 1000)}/{$id}.xml" target="_blank">{$id}</a>
        {$space}
        <b>{$typeSubtype}</b>
        {$space}
        {
            for $title in $biblio/tei:bibl/tei:title
            return <span>{string($title)}</span>
        }
        <ul>
        {
            for $title in $biblio/tei:bibl/tei:series/tei:title
            return
                <li title="{string($title/@type)}">
                    {string($title)}
                    {if($title/following-sibling::tei:biblScope[@type='volume'])then(concat(' ', string($title/following-sibling::tei:biblScope[@type='volume'])))else()}
                </li>
        }
        {
            for $title in $biblio/tei:bibl/tei:note[@type='papyrological-series']/tei:bibl/tei:title
            return
                <li title="{string($title/@type)}">
                    {string($title)}
                    {if($title/following-sibling::tei:biblScope[@type='volume'])then(concat(' ', string($title/following-sibling::tei:biblScope[@type='volume'])))else()}
                </li>
        }
        {
            for $title in $biblio/tei:note[@resp='#BP']
            return
                <li title="note BP">
                    {string($title)}
                </li>
        }
        </ul>
      </li>
}
</ul>

{
    for $i at $index in (8 to 16)
    return concat($index, '=', $i)
}
</body>
</html>