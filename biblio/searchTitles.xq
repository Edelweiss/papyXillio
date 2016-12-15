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
        <link rel="stylesheet" type="text/css" href="../resources/jquery/jquery-ui.min.css"/>
        <link rel="stylesheet" type="text/css" href="../resources/css/style.css"/>
        <style type="text/css">
            label {{ margin-right: 1em; }}
            div.query {{ padding: 1em; background: steelblue; }}
            div.results {{ height: 700px; overflow: scroll; background: lightsteelblue; }}
        </style>
        
    </head>
<body>
<h1>Biblio - Search Titles</h1>
<div class="query">
    <form action="#" method="get">

            <label for="regExp" title="e.g. ‘P\.?S\.?I\.?'">Regular Expression</label>
            <input type="text" name="regExp" required="required" value="{request:get-parameter('regExp', (''))}"/>
            <div id="chooseType">
                {
                    if(request:get-parameter('type', 'book') = 'book')then(
                        <input type="radio" name="type" value="book" id="typeBook" checked="checked"/>
                    )else(
                        <input type="radio" name="type" value="book" id="typeBook"/>
                    )
                }
                <label for="typeBook">book</label>
                {
                    if(request:get-parameter('type', 'book') = 'article')then(
                        <input type="radio" name="type" value="article" id="typeArticle" checked="checked"/>
                    )else(
                        <input type="radio" name="type" value="article" id="typeArticle"/>
                    )
                }
                <label for="typeArticle">article</label>
                {
                    if(request:get-parameter('type', 'book') = 'review')then(
                        <input type="radio" name="type" value="review" id="typeReview" checked="checked"/>
                    )else(
                        <input type="radio" name="type" value="review" id="typeReview"/>
                    )
                }
                <label for="typeReview">review</label>
                {
                    if(request:get-parameter('type', 'book') = 'journal')then(
                        <input type="radio" name="type" value="journal" id="typeJournal" checked="checked"/>
                    )else(
                        <input type="radio" name="type" value="journal" id="typeJournal"/>
                    )
                }
                <label for="typeJournal">journal</label>
            </div>
            <button type="submit" value="Submit">search</button>

    </form>
</div>
<div class="results">
<ul>
{
  let $regExp := request:get-parameter('regExp', 'P.Köln 1')
  let $type := request:get-parameter('type', 'book')
  let $space := '&#32;'
  for $biblio in collection('/data/idp.data/dclp/Biblio?select=*.xml;recurse=yes')[./tei:bibl/@type=$type][matches(string-join((./tei:bibl/tei:title, ./tei:bibl/tei:series/tei:title, ./tei:bibl/tei:note[@type='papyrological-series']/tei:bibl/tei:title, ./tei:bibl/tei:seg[@subtype='titre']), ' '), $regExp)]
    let $id := substring-after(string($biblio/tei:bibl/@xml:id), 'b')
    let $typeSubtype := concat($biblio/tei:bibl/@type, if($biblio/tei:bibl/@subtype)then(concat('-', $biblio/tei:bibl/@subtype))else())
    return
      <li>
        <a href="https://github.com/DCLP/idp.data/blob/dclp/Biblio/{ceiling(number($id) div 1000)}/{$id}.xml" target="_blank" title="{string($biblio)}">{$id}</a>
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
                <li>
                    <span title="{string($title/@type)}">
                        {string($title)}
                        {if($title/following-sibling::tei:biblScope[@type='volume'])then(concat(' ', string($title/following-sibling::tei:biblScope[@type='volume'])))else()}
                    </span>
                </li>
        }
        {
            for $title in $biblio/tei:bibl/tei:note[@type='papyrological-series']/tei:bibl/tei:title
            return
                <li>
                    <span title="{string($title/@type)}">
                        {string($title)}
                        {if($title/following-sibling::tei:biblScope[@type='volume'])then(concat(' ', string($title/following-sibling::tei:biblScope[@type='volume'])))else()}
                    </span>
                </li>
        }
        {
            for $title in $biblio/tei:bibl/tei:seg[@subtype='titre']
            return
                <li>
                    <span title="titre">
                        {string($title)}
                    </span>
                </li>
        }
        {
            for $title in $biblio/tei:bibl/tei:note[@resp='#BP']
            return
                <li>
                    <span title="note BP">
                        {string($title)}
                    </span>
                </li>
        }
        {
            for $title in $biblio/tei:bibl/tei:seg[@subtype='indexBis']
            return
                <li>
                    <span title="indexBis">
                        {string($title)}
                    </span>
                </li>
        }
        </ul>
      </li>
}
</ul>
</div>
    <script type="text/javascript" src="../resources/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="../resources/jquery/jquery-ui.min.js"></script>
    <script>
        $(function(){{
            $( "#chooseType" ).buttonset();
            $('body').tooltip();
            $('button').button({{
                icon: 'ui-icon-search',
	            showLabel: true
            }});
        }});
    </script>
</body>
</html>