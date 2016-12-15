xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace util = 'http://exist-db.org/xquery/util';
declare option output:method "html5";
declare option output:media-type "text/html";

(:

sample url

http://localhost:8080/exist/rest/db/apps/papyrillio/dclp/searchForBiblioWithoutReferencePointer.xq

:)

<html>
    <head>
        <title>DCLP - Search For Biblio Without Reference Pointer</title>
        <link rel="stylesheet" type="text/css" href="../resources/jquery/jquery-ui.min.css"/>
        <link rel="stylesheet" type="text/css" href="../resources/css/style.css"/>
        <style type="text/css">
            label {{ margin-right: 1em; }}
            div.query {{ padding: 1em; background: steelblue; }}
            div.results {{ height: 700px; overflow: scroll; background: lightsteelblue; }}
        </style>
        
    </head>
<body>
<h1>DCLP - Search For Principal Edition Without Reference Pointer</h1>
<div class="query">
    <form action="#" method="get">

            <label for="regExp" title="e.g. ‘P\.?S\.?I\.?'">Regular Expression</label>
            <input type="text" name="regExp" required="required" value="{request:get-parameter('regExp', (''))}"/>
            <button type="submit" value="Submit">search</button>
    </form>
</div>
<div class="results">
<ol>
{
  let $regExp := request:get-parameter('regExp', 'O. Abu Mina')
  let $space := '&#32;'
  for $biblio in collection('/data/idp.data/dclp/DCLP?select=*.xml;recurse=yes')//tei:div[@subtype='principalEdition']//tei:bibl[not(tei:ptr/@target)][matches(tei:title, $regExp)]
    let $title := string($biblio/tei:title)
    let $volume := string($biblio/tei:biblScope[@unit='volume'])
    let $extra := string-join($biblio/tei:biblScope[not(@unit='volume')], ' ')
    let $complete := string-join(($title, $volume, $extra), ' ')
    let $tm := string($biblio/ancestor::tei:TEI//tei:idno[@type='TM'])
    return
      <li title="{$complete}">
          <a href="https://github.com/DCLP/idp.data/blob/dclp/DCLP/{ceiling(number($tm) div 1000)}/{$tm}.xml" target="_blank">{$tm}</a>
          {$space}
          <b>
              {$title}
              {$space}
              {$volume}
          </b>
          {$space}
          {$extra}
          {$space}
          <a href="http://www.trismegistos.org/text/{$tm}" target="_blank">TM</a>
      </li>
}
</ol>
</div>
    <script type="text/javascript" src="../resources/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="../resources/jquery/jquery-ui.min.js"></script>
    <script>
        $(function(){{
            $('body').tooltip();
            $('button').button({{
                icon: 'ui-icon-search',
	            showLabel: true
            }});
        }});
    </script>
</body>
</html>