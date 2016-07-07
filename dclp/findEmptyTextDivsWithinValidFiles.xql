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
    let $r := ceiling(util:random()* $max) cast as xs:integer
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
    let $invalids := ('555', '1846')
    return
        (: 102801 should be valid
        
           Schemas
           http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng
           http://www.stoa.org/epidoc/schema/8.16/tei-epidoc.rng
           /db/data/tei-epidoc.rng
        
        :)
        <ul>{for $doc in collection("/db/apps/papyrillio/data/idp.data/dclp/DCLP?select=*.xml;recurse=yes")
            let $tm := data($doc//tei:idno[@type='TM'])
            let $file := data(replace(document-uri($doc), '^.+idp\.data/dclp/DCLP/(.+)$', 'https://github.com/DCLP/idp.data/blob/dclp/DCLP/$1'))
            let $lang := data($doc//tei:div[@type='edition']/@xml:lang)
            let $validation-report := validation:jing-report($doc, xs:anyURI('/db/data/tei-epidoc.rng'))
            let $test := data($validation-report//status)
            return if($lang = ('grc', 'la') and $test = 'valid')then
            <li id="{$tm}">
              <a href="{$file}">{$tm} ({$lang}/{$test})</a>
            </li>
            else ()
        }</ul>

};

<html>
    <head>
        <title>DCLP - empty text divs</title>
        <style type="text/css">
            body {{ width: 400px; }}
            label {{ width: 120px; display: block; float: left; }}
        </style>
    </head>
    <body>
        { local:main() }
    </body>
</html>
