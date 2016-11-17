xquery version "3.0";
(: $Id$ :)

(:~
 : Simple XQuery example without HTML templating. The entire app is contained in one file.
:)
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace config="http://localhost:8080/exist/apps/papyrillio/config" at "../modules/config.xqm";
import module namespace functx = "http://www.functx.com" at "../modules/functx-1.0-doc-2007-01.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace fm ="http://www.filemaker.com/fmpxmlresult";

declare option output:method "html5";
declare option output:media-type "text/html";

declare variable $PRECISION as xs:integer := 4;
declare variable $COMMENTS := doc('/db/data/HGV/Bemerkungen.xml');

declare function local:getBemerkungenDiff2() as node()*
{
    for $doc in collection('/db/data/idp.data/dclp/HGV_meta_EpiDoc/HGV1?select=*.xml;recurse=yes')
      let $file := data(replace(document-uri($doc), '^.+idp\.data/dclp/HGV_meta_EpiDoc/(.+)$', 'https://github.com/papyri/idp.data/blob/master/HGV_meta_EpiDoc/$1'))
      let $tm   := data($doc//tei:idno[@type='TM'])
      let $hgv  := data($doc//tei:idno[@type='filename'])
      let $commentEpiDoc := normalize-space($doc//tei:div[@type='commentary'][@subtype='general']/tei:p)
      let $commentAquila := normalize-space($COMMENTS//fm:ROW[fm:COL[1]/fm:DATA[1]=$hgv]/fm:COL[2]/fm:DATA[1])
      return
          <ul>{
      if(not(matches(document-uri($doc), '.*(DS_Store|desktop\.ini).*')) and ($commentEpiDoc = $commentAquila))then
        (<li>
            <a href="{data($file)}">{$hgv}</a>
            <ul>
                <li>{$commentAquila} (Aquila)</li>
                <li>{$commentEpiDoc} (EpiDoc)</li>
            </ul>
        </li>)
      else
        ()
        }</ul>
};

declare function local:getBemerkungenDiff5() as node()*
{
    for $comment in $COMMENTS//fm:ROW[position()<50000]
      let $hgv           := string($comment/fm:COL[1]/fm:DATA[1])
      let $tm            := replace($hgv, '[a-z]+', '')
      let $folder        := string(ceiling(number($tm) div 1000))
      let $file          := concat('/db/data/idp.data/dclp/HGV_meta_EpiDoc/HGV', $folder, '/', $hgv, '.xml')

      return <li>{$file}</li>
};

declare function local:getBemerkungenDiff() as node()*
{
    session:create(),
    let $mode := request:get-parameter("mode", ())
    for $comment in $COMMENTS//fm:ROW[position()]
      let $hgv           := normalize-space(string($comment/fm:COL[1]/fm:DATA[1]))
      let $tm            := replace($hgv, '[a-z]+', '')
      let $folder        := string(ceiling(number($tm) div 1000))
      let $github        := concat('https://github.com/papyri/idp.data/blob/master/HGV_meta_EpiDoc/HGV', $folder, '/', $hgv, '.xml')
      let $file          := concat('/db/data/idp.data/dclp/HGV_meta_EpiDoc/HGV', $folder, '/', $hgv, '.xml')
      let $epiDoc        := doc($file)
      let $commentEpiDoc := string($epiDoc//tei:div[@type='commentary'][@subtype='general']/tei:p)
      let $commentAquila := string($comment/fm:COL[2]/fm:DATA[1])
      let $countOrigDate  := count($epiDoc//tei:origDate)

      return
      if((not(string($mode)) or (($mode = 'skipDatasetsThatContainMultipleDates') and ($countOrigDate < 2) and not(contains($commentAquila, 'Alternativdatierung')))) and not($commentEpiDoc = $commentAquila))then
        (<li>
            <a href="{data($github)}">{$hgv}</a>
            <ul>
                <li>{$commentAquila} (Aquila)</li>
                <li>{$commentEpiDoc} (EpiDoc)</li>
            </ul>
        </li>)
      else
        ()
};

declare function local:getBemerkungenDiff3() as node()*
{
    for $comment in $COMMENTS//fm:ROW
      
      let $hgv  := string($comment/fm:COL[1]/fm:DATA[1])

      return
      if($hgv = '35244')then
        (<li>{$comment}
        </li>)
      else
        ()
};

<html>
    <head>
        <title>HGV - Bemerkungen</title>
        <link rel="stylesheet" type="text/css" href="../resources/css/jquery/dark-hive/jquery-ui-1.8.17.custom.css" />
        <script type="text/javascript" src="../resources/js/jquery/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="../resources/js/jquery/jquery-ui-1.8.17.custom.min.js"></script>
    </head>
    <body>
        <h3>Bemerkungen</h3>
        Prüft, welche an welchen Stellen sich die Inhalte im Feld »Bemerkungen« bei den Daten in der Aquila-FileMaker-12-Datenbank von den Inhalten der idp.data-EpiDoc-XML-Dateien unterscheiden.
        <p>
            <form method="get">
            <select name="mode">
                <option value="skipDatasetsThatContainMultipleDates">omit datasets that contain multiple dates</option>
                <option value="">show all</option>
            </select>
            <input type="submit" value="Los!"/>
            </form>
            </p>
        <ul>{ local:getBemerkungenDiff() }</ul>
        { fn:current-dateTime() }
    </body>
</html>



