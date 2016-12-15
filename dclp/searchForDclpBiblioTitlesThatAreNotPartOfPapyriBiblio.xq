xquery version "3.0";

import module namespace functx = "http://www.functx.com" at "../modules/functx-1.0-doc-2007-01.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare option output:method "html5";
declare option output:media-type "text/html";

(:

sample url

http://localhost:8080/exist/rest/db/apps/papyrillio/dclp/searchForBiblioWithoutReferencePointer.xq

:)

<html>
    <head>
        <title>DCLP - search for biblio titles that are not present in Papyri’s biblio</title>
        <link rel="stylesheet" type="text/css" href="../resources/jquery/jquery-ui.min.css"/>
        <link rel="stylesheet" type="text/css" href="../resources/css/style.css"/>
        <style type="text/css">
            label {{ margin-right: 1em; }}
            div.query {{ padding: 1em; background: steelblue; }}
            div.results {{ height: 800px; overflow: scroll; background: lightsteelblue; }}
        </style>
        
    </head>
<body>
<h1>DCLP - search for biblio titles that are not present in Papyri’s biblio</h1>

<div class="results">
<ol>
{
  let $space := '&#32;'
  for $biblio in collection('/data/idp.data/dclp/DCLP?select=*.xml;recurse=yes')//tei:div[@subtype='principalEdition']//tei:bibl[tei:ptr/@target][.//tei:title[@type, 'abbreviated']]
  let $title := string($biblio//tei:title[@type, 'abbreviated'])
  group by $title
  order by $title
    return
        let $tm := string($biblio[1]/ancestor::tei:TEI//tei:idno[@type='TM'])
        let $bilioLink := string($biblio[1]//tei:ptr/@target)
        let $biblioId := replace($bilioLink, '^[^\d]+(\d+)$', '$1')
        let $biblioFile := concat('/data/idp.data/dclp/Biblio/', ceiling(number($biblioId) div 1000), '/', $biblioId, '.xml')
        let $biblioEpiDoc := doc($biblioFile)
        let $dclpTitle := replace($title, ' ', '')
        let $biblioTitles := data($biblioEpiDoc//tei:title)
        let $match := if(contains($biblioTitles, $dclpTitle))then('yes')else('no')
        let $countDclpFiles := count($biblio)
        return
            if($match = 'no')then(
              <li>
                  <a href="http://www.trismegistos.org/text/{$tm}" target="_blank">TM</a>
                  {$space}
                  <a href="{$bilioLink}" target="_blank">Biblio</a>
                  {$space}
                  {$title}
                  {$space}
                  ({$countDclpFiles}{$space}<a href="https://github.com/DCLP/idp.data/blob/dclp/DCLP/{ceiling(number($tm) div 1000)}/{$tm}.xml" target="_blank">DCLP</a> file{if($countDclpFiles > 1)then('s')else('')})
              </li>
            )else()
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