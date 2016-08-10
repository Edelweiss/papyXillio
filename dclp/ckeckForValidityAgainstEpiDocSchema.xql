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

declare function local:getInvalidEpiDocFiles() as node()*
{
    for $doc in collection("/db/data/idp.data/dclp_hd/DCLP?select=*.xml;recurse=yes")
      let $file := data(replace(document-uri($doc), '^.+idp\.data/dclp_hd/DCLP/(.+)$', 'https://github.com/DCLP/idp.data/blob/dclp/DCLP/$1'))
      let $tm   := data($doc//tei:idno[@type='TM'])
      let $validation-report := validation:jing-report($doc, xs:anyURI('/db/data/epidoc/schema/latest/tei-epidoc.rng'))
      let $status := data($validation-report//status)
      return
      if(not(matches(document-uri($doc), '.*(DS_Store|desktop\.ini).*')) and $status = 'invalid')then
        for $message in $validation-report//message
          return <error tm="{$tm}" file="{$file}" line="{string(number(data($message/@line))+1)}" column="{data($message/@column)}">{data($message)}</error>
      else
        ()
};

declare function local:getEpiDocErrors() as node()*
{
    <ul id="errors">
    {
      for $errors in local:getInvalidEpiDocFiles()
        let $errorMessage := substring-before(data($errors), ';')
        group by $errorMessage
        return <li><b>{$errorMessage} (#{count($errors)})</b>
        <ul>
          {
            for $instance in $errors[position()<20]
              return <li><a href="{data($instance/@file)}#L{data($instance/@line)}">{if(string($instance/@tm))then(string($instance/@tm))else(concat(replace(data($instance/@file), '^.*/(\d+)\.xml.*$', '$1'), ' ???'))}</a><span> ({normalize-space(substring-after(data($instance), ';'))})</span></li>
          }
        </ul></li>
    }
    </ul>
};

<html>
    <head>
        <title>DCLP - EpiDoc errors</title>
        <link rel="stylesheet" type="text/css" href="../resources/css/jquery/dark-hive/jquery-ui-1.8.17.custom.css" />
        <script type="text/javascript" src="../resources/js/jquery/jquery-1.7.1.min.js"></script>
        <script type="text/javascript" src="../resources/js/jquery/jquery-ui-1.8.17.custom.min.js"></script>
    </head>
    <body>
        <h3>Invalid DCLP EpiDoc files</h3>
        { local:getEpiDocErrors() }
        { fn:current-dateTime() }
        
        <script type="text/javascript" src="js/dclp.js"></script>
    </body>
</html>

