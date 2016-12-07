xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace util = 'http://exist-db.org/xquery/util';
declare option output:method "html5";
declare option output:media-type "text/html";

(: 

localhost:8080/exist/rest/db/apps/papyrillio/sandbox/hgvGlossary.xq

:)

<html>
    <head>
        <title>HGV Glossary</title>
        <style type="text/css">
            label {{ width: 120px; display: block; float: left; }}
        </style>
    </head>
<body>
<h1>HGV Translation Glossary</h1>

<form action="#" method="post">
{
    let $term := request:get-parameter('term', ())
    let $en   := request:get-parameter('en', ())
    let $de   := request:get-parameter('de', ())
    let $new  := <item xml:id="g{util:random(65000)}"><term xml:lang="grc">{$term}</term>{if($en)then(<gloss xml:lang="en">{$en}</gloss>)else()}{if($de)then(<gloss xml:lang="en">{$de}</gloss>)else()}</item>
      return if(string($term))then(
          let $update := update insert $new into doc('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml')//tei:list
          return
            <p>saving new entry ({$new})<span>[UPDATE:{$update}]</span></p>
          )else()
}
<fieldset>
    <legend>Add New Translation</legend>
<label>Greek</label>
<textarea name="term" rows="4" cols="50" required="required">{request:get-parameter('term', (''))}</textarea>
<br />
<label>English</label>
<textarea name="en" rows="4" cols="50">{request:get-parameter('en', ())}</textarea>
<br />
<label>German</label>
<textarea name="de" rows="4" cols="50">{request:get-parameter('de', ())}</textarea>
<input type="submit" value="add to glossary"/>
</fieldset>
</form>

<p>
{ count(doc('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml')//tei:list/tei:item[string(normalize-space(tei:term))]) } terms
</p>
<p>
{ count(doc('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml')//tei:list/tei:item[string(normalize-space(tei:gloss[@xml:lang='en']))]) } English translations
</p>
<p>
{ count(doc('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml')//tei:list/tei:item[string(normalize-space(tei:gloss[@xml:lang='de']))]) } German translations
</p>
<ul>
{for $glossary in doc('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml')//tei:list/tei:item
  let $term := $glossary/tei:term/text()
  let $language := string($glossary/tei:term/@xml:lang)
  let $id := string($glossary/@xml:id)
  where
    $term
  order by
    $term
  return
    <li>
      <a title="{$language}" href="#{$id}">{$term}</a>
    </li>
}
</ul>

{
    for $i in (1 to 10)
    return $i
}
<ul>
{for $glossary at $index in doc('/db/data/idp.data/dclp/HGV_trans_EpiDoc/glossary.xml')//tei:list/tei:item
  let $term := $glossary/tei:term/text()
  let $language := string($glossary/tei:term/@xml:lang)
  let $id := string($glossary/@xml:id)
  let $glossList := $glossary/tei:gloss
  where
    $term
  order by
    $term
  return
    <li id="{$id}" title="Index No. {$index}">
      <b title="{$language}">{$term}</b>
      {for $gloss in $glossList
          return <p title="{$gloss/@xml:lang}">{$gloss/text()}</p>
      }
    </li>
}
</ul>
</body>
</html>