xquery version "3.0";
(: $Id$ :)

(:~
 : Simple XQuery example without HTML templating. The entire app is contained in one file.
:)
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace config="http://localhost:8080/exist/apps/papyrillio/config" at "../modules/config.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:random($max as xs:integer) 
as empty()
{
    let $r := ceiling(util:random() * $max) cast as xs:integer
    return (
        session:set-attribute("random", $r),
        session:set-attribute("guesses", 0)
    )
};

declare function local:guess($guess as xs:integer,
$rand as xs:integer) as element()
{
    let $count := session:get-attribute("guesses") + 1
    return (
        session:set-attribute("guesses", $count),
        if ($guess lt $rand) then
            <p>[Guess {$count}]: Your number is too small!</p>
        else if ($guess gt $rand) then
            <p>[Guess {$count}]: Your number is too large!</p>
        else
            let $newRandom := local:random(100)
            return
                <p>Congratulations! You guessed the right number with
                {$count} tries. Try again!</p>
    )
};

declare function local:main() as node()?
{
    session:create(),
    let $jourFixe := xs:date(request:get-parameter("date", ()))
    return
      if(not(empty($jourFixe)))
      then(
        <ul>{for $doc in collection("/db/apps/papyrillio/data/idp.data/dclp/HGV_meta_EpiDoc?select=*.xml;recurse=yes")
            let $figures := $doc/tei:TEI/tei:text/tei:body/tei:div[@type='figure']/tei:p/tei:figure
            let $hgvDate := normalize-space(data($doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]))
            let $id := data($doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename'])
            let $title := data($doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)
            let $date := xs:date($doc/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change[position()=last()]/@when)
            let $publication := normalize-space(string-join($doc/tei:TEI/tei:text/tei:body/tei:div[@type='bibliography'][@subtype='principalEdition']/tei:listBibl/tei:bibl[@type='publication'][@subtype='principal'], ' '))
            let $file := data(replace(document-uri($doc), '^.+idp\.data/HGV_meta_EpiDoc/(.+)$', '$1'))
            return if($date >= $jourFixe and count($figures) > 0 and $hgvDate != 'unbekannt')then
            <li file="{$file}" id="{$id}" date="{$date}" jourFixe="{data($jourFixe)}">
            <a href="http://www.papyri.info/hgv/{$id}">{$publication} ({$title})</a> → {$hgvDate}
            <ul>{
            for $figure in $figures
            return <li><a href="{data($figure/tei:graphic/@url)}">{data($figure/tei:graphic/@url)}</a></li>
            }</ul>
            </li>
            else ()
        }</ul>
      )
      else(
        <p>please enter a date like '2012-01-01' in the input box above</p>
      )
};

<html>
    <head>
        <title>Latest HGV changes</title>
        <style type="text/css">
            body {{ width: 400px; }}
            label {{ width: 120px; display: block; float: left; }}
        </style>
    </head>
    <body>
        <p>Enter a data (e.g. 2012-01-01)</p>
        <form action="{session:encode-url(request:get-uri())}">
            <div>
                <label for="date">Date:</label>
                <input type="text" name="date" size="10" autofocus="autofocus" required="required"/>
            </div>
            <input type="submit"/>
        </form>
        { local:main() }
        <p>
            <a href="index.html">Back to examples</a>
        </p>
    </body>
</html>
